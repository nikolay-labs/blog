---
title: psql embeddings over http in 15 minutes
subtitle: how to set bring embedding-search into your app in 15 minutes
keywords: psql;pgvector;supabase;embeddings;http;
category: main
author: nikolay
date: Aug 27, 2024
description: search text like the big boys at google
---

# 🚀 psql embeddings over http in 15 minutes

If you just want an embedding service go [here](#-set-up-supabase-project)

## 👋 hi

Hi I'm nikolay. I'm a pro developer working on my own ideas and I have til midnight tonight (2024/09/27) to build a clone of [sage by buildspace](https://sage.buildspace.so).

### 🤔 erm why are you cloning sage?

[Buildspace](https://buildspace.so/) is [closing down](https://buildspace.so/final). I went thru s4 last year. I didn't win, go viral or have any moderate local success. What I did gain is undying resolve to buidl ™️️ . I've met cool ppl on sage, I thought we could keep it going.

### ⏱️ why build it in one day?

why not?

## 📚 background

Ever wanted to search over some documents like its 2023? Start the clock, let's set up an embedding service.

This setup is optimised for speed to production and simplicity. This means:

- managed [Supabase](https://supabase.com/) postgres for storage
- supabase functions for API endpoints.

First we need text to embed. I will use _user bios_ from a service called `sage-clone`. Any text will work: valentine's day cards, pokemon card descriptions, your poetry collection; go wild!

For my example I want to:

1. embed bio _sections_. not whole profile because we want to piggyback off the semantics offered by splitting a bio into sections
2. query against bio sections

Supabase have great support for embeddings and a [lot of case-studies](https://supabase.com/docs/guides/ai) to learn from. Let's set it up.

## 🚀 set up supabase project

Let's set up supabase.

```bash
supabase init
supabase start # start the local workspace (might take a minute)
supabase link --project-ref $YOUR_PROJECT_REF
supabase functions new embed && supabase functions new query
```

Check the embeddings work by replacing the `embed/index.ts` with

```ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const session = new Supabase.ai.Session("gte-small");

Deno.serve(async (req) => {
  // Extract input string from JSON body
  const { input } = await req.json();

  // Generate the embedding from the user input
  const embedding = await session.run(input, {
    mean_pool: true,
    normalize: true,
  });

  // Return the embedding
  return new Response(
    JSON.stringify({ embedding }),
    { headers: { "Content-Type": "application/json" } },
  );
});
```

Run `supabase functions serve` and curl the endpoint!

## 🗃️ configure supabase postgres to store embeddings

Create the initial migration with

```bash
supabase migrations new init
```

This will set up the database for us to store and query our embeddings. This is the real meat and potatoes of this operation. Read the comments for the explanation of each step.

```sql
-- Step 1: Create a new schema for bios
CREATE SCHEMA IF NOT EXISTS bios;
grant usage on schema bios to postgres, service_role;

-- Step 2: Enable the pgvector extension for vector operations
CREATE EXTENSION IF NOT EXISTS vector;

-- Step 3: Create the bio_sections table in the new schema
CREATE TABLE bios.bio_sections (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    section_type TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding VECTOR(384),
    token_count INT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
alter table bios.bio_sections enable row level security;

-- Step 4: Create function for matching similar bio sections
CREATE OR REPLACE FUNCTION bios.match_similar_bio_sections(
    query_embedding VECTOR(384),
    similarity_threshold FLOAT,
    max_results INT
)
RETURNS TABLE (
    user_id UUID,
    section_type TEXT,
    content TEXT,
    similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        bs.user_id,
        bs.section_type,
        bs.content,
        1 - (bs.embedding <=> query_embedding) AS similarity
    FROM
        bios.bio_sections bs
    WHERE
        1 - (bs.embedding <=> query_embedding) > similarity_threshold
    ORDER BY
        bs.embedding <=> query_embedding
    LIMIT max_results;
END;
$$;

-- Step 5: Set privileges for the bios schema
ALTER DEFAULT PRIVILEGES IN SCHEMA bios
GRANT ALL ON TABLES TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE 
ON ALL TABLES IN SCHEMA bios 
TO postgres, service_role;
GRANT USAGE, SELECT 
ON ALL SEQUENCES IN SCHEMA bios 
TO postgres, service_role;
```

Bravely push the migration straight to prod! 🚀

__NB__: Don't forget to make the `bios` schema visible in API in Supabase project settings in the __browser__.

## 🔧 setting up the functions

The functions are quite simple. The shell is identical:

```ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// set up supabase, Supabase runtime sets the Env vars.
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const supabase = createClient(supabaseUrl!, supabaseServiceRoleKey!, {
  db: {
    schema: "bios", // point at schema we're working with
  },
});

// Supabase comes bundled with an embedding model already.
const session = new Supabase.ai.Session("gte-small");

Deno.serve(async (req) => {
  try {
    // YOUR FUNCTION GOES HERE
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 500 },
    );
  }
});
```

The function body of `functions/add_embedding/index.ts` and `functions/query_embedding/index.ts` are again very simple.

First, embed the bio section and upsert.

```ts
    const { userId, sectionType, content } = await req.json();

    // Generate the embedding from the user input
    const embedding = await session.run(content, {
      mean_pool: true,
      normalize: true,
    });

    // upsert the content into the bios_sections table
    const { data, error } = await supabase
      .from("bio_sections")
      .upsert(
        {
          user_id: userId,
          section_type: sectionType,
          content,
          embedding,
        },
        {
          onConflict: ["user_id"],
        },
      );

    if (error) throw error;

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });

```

Query the sections:

```ts
    const { query } = await req.json();

    if (!query) {
      throw new Error("Missing query parameter");
    }

    // Generate the embedding from the user input
    const embedding = await session.run(query, {
      mean_pool: true,
      normalize: true,
    });

    const { data: bioSections } = await supabase.rpc(
      "match_similar_bio_sections",
      {
        query_embedding: embedding, // Pass the embedding you want to compare
        similarity_threshold: 0.3, // Choose an appropriate threshold for your data
        max_results: 10, // Choose the number of matches
      },
    );

    return new Response(JSON.stringify(bioSections), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
```

After running `supabase functions deploy` our embedding service is live. We can access it over HTTP with a Supabase API Key.

```bash
curl --request POST 'http://localhost:54321/functions/v1/add_embedding' \
  --header 'Authorization: Bearer ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{ "userId": "f918dbb0-fd13-470c-98e9-3d92dfc57ce3", "sectionType": "swag", "content": "i'm a little teapot short and stout" }'
```

🎉 Congratulations! You've set up your psql embedding pipeline in 15 minutes! 🎉
