package;

import sys.io.Process;
import sys.thread.Deque;
import sys.thread.Thread;

class CLI {
    static var stdoutDeque:Deque<String>;

    static function readLineWithTimeout(timeout:Float = 0.1, checks:Int = 3) {
        for (i in 0...checks) {
            //trace("stuck there");
            var nextLine = stdoutDeque.pop(false);
            trace (nextLine);
            if (nextLine == null) {
                trace(timeout / checks);
                Sys.sleep(timeout / checks);
            }
            else return nextLine;
        }
        return null;
    }

    public static function main() {
        var args = Sys.args();
        var inkFile = if (args.length == 1) args[0] else "test.ink";
        //trace(inkFile);
        var process = new Process("./inklecate.exe", ["-p", inkFile]);
        var stdout = process.stdout;
        var stdin = process.stdin;
        var stderr = process.stderr;
        stdoutDeque = new Deque();
        var stdoutThread = Thread.create(() -> {
            try while (true) {
                //trace("stuck here");
                var nextLine = stdout.readLine();
                //trace (nextLine);
                stdoutDeque.add(nextLine);
            } catch (e) {
                // Eof
                trace ("eof");
            }
        });
        //var exitCode = process.exitCode(true);
        //trace(exitCode);
        trace(readLineWithTimeout());
        trace(readLineWithTimeout());
        trace(readLineWithTimeout());
        trace(readLineWithTimeout());
        // No more lines after the two choices
        trace(readLineWithTimeout());
        stdin.writeString("1\n");
        // CAn it recover from EOF?
        trace(readLineWithTimeout());
        trace(readLineWithTimeout());
    }
}