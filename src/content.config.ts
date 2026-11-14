import { defineCollection, z } from 'astro:content'
import { glob } from 'astro/loaders'

const news = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/news' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    categories: z.preprocess((v) => (typeof v === 'string' ? [v] : v), z.string().array()).default(['update']),
  }),
})

export const collections = { news }
