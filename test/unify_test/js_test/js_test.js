eval(require('fs').readFileSync('./test_unify.js', 'utf8')); 
var fs = require('fs');
var assert = require('assert');

var obj_ser = buildObject();

var ca = obj_ser.serialize();
serialize(ca);
var read = deserialize();

var obj_deser = new UnifySer();
obj_deser.deserialize(new BabelDataReader(read));
compare(obj_ser, obj_deser);

function buildObject(){
  var obj = new UnifySer();
  //obj.i8 = 15;
  //obj.i32 = 154210145;
  //obj.i16 = 15485;
  obj.str   = "What is This?";
  //obj.ip = "";
  obj.map1[2] = 15;
  obj.map1[3] = 16;
  return obj;
}

function compare(obj1, obj2){
  console.log(obj2);
  console.log(obj1);
  assert.equal(obj1.map1[2], obj2.map1[2]);
  assert.equal(obj1.str, obj2.str);
}

function serialize(obj){
  var bBuffer = new Buffer(obj);
  fs.writeFileSync(__dirname +  '/bin.babel.js', bBuffer, function (err) {
    if (err) {
      return console.log(err);
    }
  });
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
