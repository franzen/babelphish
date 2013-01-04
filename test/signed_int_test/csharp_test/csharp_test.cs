using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using divine;
using NUnit.Framework;

namespace test_signed_int
{
    [TestFixture]
    class divine
    {
        [Test]
        public static void Main(String[] args)
        {
	    System.Console.Write("Test Signed Int  \n");
            SignedInt ser = buildObj();
            serialize(ser);
            byte[] res = deserialize();

            SignedInt deser = new SignedInt();
            deser.deserialize(new MemoryStream(res));

            compare(ser, deser);
   
            //System.Console.Read();
            
        }

        public static SignedInt buildObj() {
		SignedInt obj = new SignedInt();
		obj.list1.Add(-1);
		obj.list1.Add(-2);
		obj.list1.Add(-3);
		obj.list1.Add(int.MaxValue);
		obj.list1.Add(int.MinValue);

		obj.list2.Add(-1);
		obj.list2.Add(-2);
		obj.list2.Add(-3);
		obj.list2.Add( (long) Math.Pow(2, 53) -1 );
		obj.list2.Add( (long) (Math.Pow(2, 53) - Math.Pow(2, 54)) );
            return obj;
	    }

        public static void compare(SignedInt obj1, SignedInt obj2)
        {
            for (int i = 0; i < obj1.list1.Count; i++)
            {
                //System.Console.Write("Ser = " + obj1.list1[i] + ", Deser = " + obj2.list1[i] + "\n");
                Assert.AreEqual(obj1.list1[i], obj2.list1[i]);
            }
            for (int i = 0; i < obj1.list2.Count; i++)
            {
                //System.Console.Write("Ser = " + obj1.list2[i] + ", Deser = " + obj2.list2[i] + "\n");
                Assert.AreEqual(obj1.list2[i], obj2.list2[i]);
            }
        }

        public static void serialize(BabelBase obj)
        {
            try
            {
                byte[] data = obj.serialize();
                File.WriteAllBytes("test/signed_int_test/csharp_test/bin.babel.csharp", data);                
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }

	    public static byte[] deserialize(){
            try
            {
                byte[] data = File.ReadAllBytes("test/signed_int_test/csharp_test/bin.babel.csharp");
                return data;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }
            
    }
}
