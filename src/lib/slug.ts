export function postSlug(id: string): string {
  return id.replace(/^\d{4}-\d{2}-\d{2}-/, '')
}
