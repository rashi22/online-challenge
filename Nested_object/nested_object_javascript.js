//Use https://onecompiler.com/javascript/ to run below script

//Javascript lodash library

const _ = require("lodash");

var object = {"a": { "b": { "c": "d" }}};

console.log("Result at 'a.b.c': ",_.get(object, 'a.b.c'));  //_.get function gets the value at path of object

var object2 = {"x":{"y":{"z":"a"}}};

console.log("Result at 'x.y.z': ",_.get(object2, 'x.y.z'));

