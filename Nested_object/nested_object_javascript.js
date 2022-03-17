var object = {"a": { "b": { "c": "d" }}};

console.log("Result at 'a.b.c': ",_.get(object, 'a.b.c'));  //_.get function gets the value at path of object

var object2 = {"x":{"y":{"z":"a"}}};

console.log("Result at 'x.y.z': ",_.get(object2, 'x.y.z'));

<script src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.11/lodash.js"></script>  //Javascript lodash library