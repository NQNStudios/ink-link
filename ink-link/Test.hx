package;

import sys.io.Process;

class Test {
    public static function main() {
        var process = new Process("./inklecate.exe", ["-p", "test.ink"]);
        var stdout = process.stdout;
        var stdin = process.stdin;
        var stderr = process.stderr;
        //var exitCode = process.exitCode(true);
        //trace(exitCode);
        trace(stdout.readLine());
        trace(stdout.readLine());
        trace(stdout.readLine());
        trace(stdout.readLine());
        stdin.writeString("1\n");
        trace(stdout.readLine());
        trace(stdout.readLine());
    }
}