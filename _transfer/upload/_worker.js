export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const key = url.searchParams.get("k");
    if (!key || key.length < 16) return new Response("bad key", { status: 400 });

    if (request.method === "GET") {
      const v = await env.TASKS.get(key);
      return new Response(v ?? "{}", {
        headers: { "content-type": "application/json", "cache-control": "no-store" }
      });
    }
    if (request.method === "PUT") {
      const body = await request.text();
      if (body.length > 200000) return new Response("too large", { status: 413 });
      await env.TASKS.put(key, body);
      return new Response("ok");
    }
    return new Response("method not allowed", { status: 405 });
  }
}
