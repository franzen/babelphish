public package testip;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;
import java.nio.charset.Charset;

class IPV6 extends BabelBase {
	public ArrayList<String> list1 = new ArrayList<String>();

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
		// Serialize list 'list1'
		writeInt32(list1.size(), baos);
		for(int var_101=0; var_101<list1.size(); var_101++) {
			String var_100 = list1.get(var_101);
			writeIpNumber(var_100, baos);
		}
	}

	@Override
	void deserialize(ByteArrayInputStream bais) throws IOException {
		// Deserialize list 'list1'
		this.list1 = new ArrayList<String>();
		int var_102 = (int)this.readInt32(bais);
		for(int var_104=0; var_104<var_102; var_104++) {
			String var_103 = readIpNumber(bais);
			this.list1.add(var_103);
		}
	}
}
