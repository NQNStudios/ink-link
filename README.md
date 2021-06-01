# ink-link
Pretend your favorite Haxe target language has an Ink port on par with InkJS

This is a dirty hack to run Ink scripts in weird environments.

Dependencies:
- Mono (for Inklecate)
- NodeJS (for InkJS)
- Haxe (for running ink-link)

Setup:

```
(cd backend && npm install .)
haxelib install hxnodejs
(cd backend && haxe build.hxml)
```

Usage:

`node index.js [inkFile]`

Limitations:
- No external functions
- Only supports Windows
- Not for production use