eval(require('fs').readFileSync('./test_complex.js', 'utf8')); 
var assert = require('assert');
var fs = require('fs');

var com_ser = buildObject();

//var ca = com_ser.serialize();
//serialize(ca);
var read = deserialize();

var com_deser = new Complex();
com_deser.deserialize(new BabelDataReader(read));
compare(com_ser, com_deser);

function buildObject(){
  var ipList_1 = new IPList();
  ipList_1.list1 = ["10.2.2.1","127.0.0.1","129.36.58.15"];

  var ipList_2 = new IPList();
  ipList_2.list1 = ["100.20.20.10","17.10.10.1","12.36.68.105"];

  var com_ser = new Complex();
  com_ser.list1 = [{}];
  var m = {};
  m["AA"] = [ipList_1, ipList_2];
  var n = {};
  n["BB"] = [ipList_2, ipList_1];
  com_ser.list1[0] = m;
  com_ser.list1[1] = n;
  return com_ser;
}

function compare(obj1, obj2){
  assert.equal(obj1.list1.length, obj2.list1.length);
  assert.equal(obj1.list1[0]["AA"].length, obj2.list1[0]["AA"].length);
  assert.equal(obj1.list1[0]["AA"][0].list1.length, obj2.list1[0]["AA"][0].list1.length);
  assert.equal(obj1.list1[0]["AA"][0].list1[2], obj2.list1[0]["AA"][0].list1[2]);
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
  var file = __dirname +  '/bin.babel.java'
  console.log(file);
  var data = fs.readFileSync(file);
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
