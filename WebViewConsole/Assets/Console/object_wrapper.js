/**
 * Wrap js object before posting message to host application.
 * @param {*} o 
 * @param {number} depth depth 
 * 
 * @returns {
 *      { __type: 'undefined' | 'boolean' | 'number' | 'bigint' | 'string' | 'function' | 'null' | 'date' | 'array' | 'object' | 'stringified_object' | 'unknown',
 *        __value: any,
 *        __error: any? }} 
 */
function wrapObject(o, depth = 1) {
    try {
        var objectType = typeof o;
        if (objectType === 'undefined' ||
            objectType === 'boolean' ||
            objectType === 'number' ||
            objectType === 'bigint' ||
            objectType === 'string') {
            // iOS bridge would convert `undefined`, `boolean`, `number`, `bigint` to NSNumber
            return { __type: objectType, __value: o }
        } else if (objectType === 'function') {
            if (depth === 0) {
                return { __type: objectType }
            }
            return { __type: objectType, __value: o.toString() };
        } else if (objectType === 'object') {
            if (o === null) {
                return { __type: 'null' }
            }
            if (o instanceof Date) {
                return { __type: 'date', __value: o };
            }
            if (depth === 0) {
                return { __type: 'stringified_object', __value: Object.prototype.toString.call(o) };
            }
            if (Array.isArray(o)) {
                return { __type: 'array', __value: o.map((element) => (wrapObject(element, depth - 1))) };
            }
            var newObject = {};
            for (var key in o) {
                try {
                    newObject[key] = wrapObject(o[key], depth - 1);
                } catch (error) {
                    newObject[key] = { __type: 'unknown', __error: error.toString() }
                }

            }
            return { __type: 'object', __value: newObject };
        } else {
            return { __type: objectType, __value: Object.prototype.toString.call(o) };
        }
    } catch (error) {
        return { __type: 'unknown', __error: error.toString() };
    }
}

