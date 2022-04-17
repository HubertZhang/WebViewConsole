(function (config) {

    if (window.__DebugConsole) return;

    window.__DebugConsole = {};

    if (!window.console) return;
    function isNumber(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }
    function __forwardConsoleCall(consoleCall) {
        var interfaceName = config && config['handler'];
        if (interfaceName) {
            consoleCall['args'] = __wrapArgs(consoleCall['args']);
            // window[interfaceName].invoke('privateConsoleLog', params);
            window.webkit.messageHandlers[interfaceName].postMessage(consoleCall);
        }
    }
    function __updateParams(params, error) {
        var stack = error.stack;
        do {
            if (!stack.length) break;

            var caller = stack.split("\n")[1];

            if (!caller) break;

            var info = caller;

            var at_index = caller.indexOf("@");

            if (at_index < 0 || at_index + 1 >= caller.length) {
                info = caller;
            } else {
                info = caller.substring(at_index + 1, caller.length);
            }

            do {
                function getLastNumberAndTrimInfo() {
                    var colon_index = info.lastIndexOf(":");

                    if (colon_index < 0 || colon_index + 1 >= info.length) {
                        return -1;
                    }

                    var column = info.substring(colon_index + 1);

                    if (!isNumber(column)) {
                        return -1;
                    }

                    info = info.substring(0, colon_index);

                    return column;
                }

                // parse column no
                var colno = getLastNumberAndTrimInfo();
                if (colno == -1) break;
                params.colno = colno;

                // parse line no
                var lineno = getLastNumberAndTrimInfo();
                if (lineno == -1) break;
                params.lineno = lineno;

                // the rest is file
                params.file = info;
            } while (0);
        } while (0);

        if (!params.lineno && params.colno) {
            params.lineno = params.colno;
            delete params.colno;
        }
        return params;
    }
    function __wrapArgs(args) {
        if (config['wrapper'] && typeof config['wrapper'] === 'function') {
            var result = [];
            var n = args.length;
            for (var i = 0; i < n; i++) {
                arg = args[i];
                result.push(config['wrapper'](arg));
            }
            return result;
        } else {
            return args;
        }
    }
    for (var key in console) {
        (function (name) {
            var func = console[name];
            if (typeof func != 'function') return;
            console[name] = function () {
                var args = Array.prototype.slice.call(arguments, 0);
                func.apply(console, args);

                var params = {
                    'func': name,
                    'args': args,
                };

                // retrive caller info
                try {
                    throw Error("");
                } catch (error) {
                    params = __updateParams(params, error);
                }
                __forwardConsoleCall(params);
            }
        }(key));
    }

    // catch errors
    (function () {

        window.addEventListener('error', function (event) {
            var params = {
                'func': 'error',
                'args': [event.message],
                'file': event.filename,
                'colno': event.colno,
                'lineno': event.lineno,
            };
            __forwardConsoleCall(params);
        });
    }());
})
