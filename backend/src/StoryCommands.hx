package;

import sys.io.File;

using StringTools;
using StoryCommands;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.TypeTools;
using tink.MacroApi;
#end

/**
 * Generate a command-line handler that provides every Story API function possible
 * by processing the Haxe expressions in Story.hx
 */
class StoryCommands {
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();

        var storyExternHaxe = File.getContent(".haxelib/inkjs/2,0,0/inkjs/engine/story/Story.hx");

        var storyExternBodyStart = storyExternHaxe.indexOf("{")+1;
        var storyExternBodyEnd = storyExternHaxe.lastIndexOf("}");
        var storyFieldExprs = storyExternHaxe.substr(storyExternBodyStart, storyExternBodyEnd - storyExternBodyStart).split(";");

        var processCommandCases:Array<Case> = [];

        for (expr in storyFieldExprs) {
            expr = expr.trim();

            if (expr.startsWith("//")) {
                expr = expr.substr(expr.indexOf("\n")+1);
            }
            if (expr.startsWith("/*")) {
                expr = expr.substr(expr.indexOf("*/")+2);
            }
            if (expr.startsWith("function")) {
                expr += " {}";
            } 

            expr = expr.trim();
            var parsedExpr = try {
                // Pretend functions have bodies so they parse
                Context.parse(expr, Context.currentPos());
            } catch (e) {
                // Sys.println('Cannot convert Story API `${expr.trim()}` for command line usage because $e');
                continue;
            };

            // Add to processCommandCases

            switch (parsedExpr.expr) {
                case EVars([v]):
                    processCommandCases.push({
                        values: [EArrayDecl([EConst(CString(v.name, DoubleQuotes)).at()]).at()],
                        expr: macro Sys.println($p{["story", v.name]})
                    });
                case EFunction(FNamed(name, _), {
                    ret: ret,
                    expr: expr,
                    args: []
                }):
                    processCommandCases.push({
                        values: [EArrayDecl([EConst(CString(name, DoubleQuotes)).at()]).at()],
                        expr: if (ret.toString() != "Void") {
                            macro Sys.println($p{["story", name]}());
                        } else {
                            macro $p{["story", name]}();
                        }
                    });
                case EFunction(FNamed(name, _), {
                    ret: ret,
                    expr: expr,
                    args: args
                }):
                    var argStuff = "";
                    var arrayPattern = [EConst(CString(name, DoubleQuotes)).at()];
                    var callArgs = [];
                    var canConvert = true;

                    for (arg in args) {
                        argStuff += arg.type.toString() + " ";
                        arrayPattern.push(macro $i{arg.name});
                        switch (arg.type.toString()) {
                            case "String":
                                callArgs.push(macro $i{arg.name});
                            case "Float":
                                callArgs.push(macro Std.parseFloat($i{arg.name}));
                            // Bools could easily also be converted, but there don't seem to be any functions
                            // that take bools without taking complicated types as well
                            default:
                                canConvert = false;
                        }
                    }
                    // Sys.println('NAME $name RET ${ret.toString()} ARGS $argStuff');
                    if (!canConvert) {
                        // Sys.println("skipped!");
                        continue;
                    }
                    processCommandCases.push({
                        values: [EArrayDecl(arrayPattern).at()],
                        expr: if (ret.toString() != "Void") {
                            macro Sys.println($p{["story", name]}($a{callArgs}));
                        } else {
                            macro $p{["story", name]}($a{callArgs});
                        }
                    });
                default:
                    Sys.println(expr);
                    Sys.println(parsedExpr.expr);
            }

        }

        var switchExp = ESwitch(
            macro (command : Array<String>),
            processCommandCases,
            macro Sys.println('error! bad command $command')
            ).at();
        // trace(switchExp.toString());

        var processCommandFunction = {
            expr:
                //macro switch (command: Array<String>) { case ["fuck"]: Sys.println("yes"); },
                switchExp,
            args: [{
                name: "command"
            }]
        };
        fields.push({
            pos:Context.currentPos(),
            name: "processCommand",
            kind:FFun(processCommandFunction),
            access:[APublic]
        });
        
        return fields;
    }
}