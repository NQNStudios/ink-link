# ink-link
Pretend your favorite Haxe target language has an Ink port on par with InkJS

This is a dirty hack to run Ink scripts in weird environments.

## Dependencies
- Dotnet Core (for Inklecate)
- NodeJS (for InkJS)
- Haxe (for running ink-link)

## Setup

```
(cd backend && npm install .)
haxelib install hxnodejs
haxelib install tink_macro
(cd backend && haxe build.hxml)
```

## Usage:

### Command-line repl

```
node index.js [inkFile]
```

### Synchronous console commands

```
node index.js --start-sync [inkFile]
node index.js --sync [command...]
...
```

## Limitations

- No external functions
- Only supports Windows
- Not for production use