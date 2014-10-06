eval(require('fs').readFileSync('test/dynamic_int_test/js_test/test_dynamic_int.js', 'utf8'));
var fs = require('fs');
var assert = require('assert');

console.log("Test Dynamic Int");

var obj_ser = buildObject();

var ca = obj_ser.serialize();
serialize(ca);
var read = deserialize();

var obj_deser = new DynamicInt();
obj_deser.deserialize(new DivineDataReader(read));
compare_list(obj_ser.list1, obj_deser.list1);


function buildObject(){
  var obj  = new DynamicInt();
  obj.list1   = [127, 16383, 2097151, 268435455, 34359738367, 4398046511103, 562949953421311]//, 9007199254740991];
  return obj;
}

function compare_list(lst_1, lst_2){
  assert.equal(lst_1.length, lst_2.length)
  for (var i = 0; i < lst_1.length; i++){
    //console.log("Ser = " + lst_1[i] + ", Deser = " + lst_2[i]);
    assert.equal(lst_1[i], lst_2[i]);
  }
}

function serialize(obj){
  var bBuffer = new Buffer(obj);
  fs.writeFileSync(__dirname +  '/bin.babel.js', bBuffer);
}

function deserialize(){
  var data = fs.readFileSync(__dirname +  '/bin.babel.js');
  data = toArray(data);
  return data;
  
}

function toArray(buffer) {
    var view = new Uint8Array(buffer.length);
    for (var i = 0; i < buffer.length; ++i) {
        view[i] = buffer[i];
    }
    return view;
}
