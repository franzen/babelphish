eval(require('fs').readFileSync('test/binaryTree_test/js_test/test_binaryTree.js', 'utf8')); 
var assert = require('assert');
var fs = require('fs');
console.log("Test Binary Tree");

var binaryTree_ser = buildTree();
var ca = binaryTree_ser.serialize();
serialize(ca);
var read = deserialize();
var binaryTree_deser = new BinaryTree();
binaryTree_deser.deserialize(new DivineDataReader(read));
compareBinaryTree(binaryTree_ser, binaryTree_deser);


function buildTree(){
    var root = new Node();
    root.i32 = 0;
    root.b = false;
    
    var n1_L = new Node();
    n1_L.i32 = 1;
    n1_L.b = true;

    var n1_R = new Node();
    n1_R.i32 = 2;
    n1_R.b = false;

    var n2_L_L = new Node();
    n2_L_L.i32 = 3;
    n2_L_L.b = true;

    var n2_L_R = new Node();
    n2_L_R.i32 = 4;
    n2_L_R.b = false;

    var n2_R_L = new Node();
    n2_R_L.i32 = 5;
    n2_R_L.b = true;

    var n2_R_R = new Node();
    n2_R_R.i32 = 6;
    n2_R_R.b = false;

    root.next_node = [n1_L, n1_R];
    n1_L.next_node = [n2_L_L, n2_L_R];
    n1_R.next_node = [n2_R_L, n2_R_R];
    
    var bt = new BinaryTree();
    bt.root_node = [root];
    return bt;
}

function compareBinaryTree(bt1, bt2){
  assert.equal( bt1.root_node.length, bt2.root_node.length);
  assert.equal( bt1.root_node[0].b, bt2.root_node[0].b);
  assert.equal( bt1.root_node[0].i32, bt2.root_node[0].i32);
  assert.equal( bt1.root_node[0].next_node.length, bt2.root_node[0].next_node.length);
  assert.equal( bt1.root_node[0].next_node[0].next_node[0].i32, bt2.root_node[0].next_node[0].next_node[0].i32);
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

