# Test-only stand-in for the Anthropic Messages API (not part of the template).
import json, socket, uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
class H(BaseHTTPRequestHandler):
    def log_message(self, *a): print("stub", self.command, self.path, flush=True)
    def _json(self, code, obj):
        b = json.dumps(obj).encode(); self.send_response(code)
        self.send_header("content-type", "application/json"); self.send_header("content-length", str(len(b))); self.end_headers(); self.wfile.write(b)
    def do_GET(self): self._json(200, {"ok": True, "data": []})
    def do_HEAD(self): self.send_response(200); self.end_headers()
    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers.get("content-length") or 0)) or b"{}")
        if "count_tokens" in self.path: return self._json(200, {"input_tokens": 10})
        if not self.path.startswith("/v1/messages"): return self._json(200, {})
        text = "STUB-REPLY: hello from the test stub."
        mid = "msg_" + uuid.uuid4().hex[:20]; model = body.get("model", "claude-stub")
        msg = {"id": mid, "type": "message", "role": "assistant", "model": model, "content": [], "stop_reason": None, "stop_sequence": None, "usage": {"input_tokens": 10, "output_tokens": 0}}
        if not body.get("stream"):
            msg.update(content=[{"type": "text", "text": text}], stop_reason="end_turn", usage={"input_tokens": 10, "output_tokens": 8})
            return self._json(200, msg)
        self.send_response(200); self.send_header("content-type", "text/event-stream"); self.end_headers()
        def ev(t, d): self.wfile.write(f"event: {t}\ndata: {json.dumps(d)}\n\n".encode()); self.wfile.flush()
        ev("message_start", {"type": "message_start", "message": msg})
        ev("content_block_start", {"type": "content_block_start", "index": 0, "content_block": {"type": "text", "text": ""}})
        ev("content_block_delta", {"type": "content_block_delta", "index": 0, "delta": {"type": "text_delta", "text": text}})
        ev("content_block_stop", {"type": "content_block_stop", "index": 0})
        ev("message_delta", {"type": "message_delta", "delta": {"stop_reason": "end_turn", "stop_sequence": None}, "usage": {"output_tokens": 8}})
        ev("message_stop", {"type": "message_stop"})
class S(ThreadingHTTPServer):
    address_family = socket.AF_INET6
    def server_bind(self):
        self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0); super().server_bind()
import os
S(("::", int(os.environ.get("PORT", "8080"))), H).serve_forever()
