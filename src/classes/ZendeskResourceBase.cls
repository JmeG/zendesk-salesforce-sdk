public abstract class ZendeskResourceBase extends ZendeskTypes {

	protected final ZendeskConnection zconn;

    public ZendeskResourceBase(ZendeskConnection zconn) {
		this.zconn = zconn;
	}

	// Realllly hacky way of stripping out nulls. Experimenting with this instead of using deserializeUntyped
	// https://iwritecrappycode.wordpress.com/2014/07/16/stripping-nulls-from-a-json-object-in-apex/
	public static string stripJsonNulls(String jsonString) {
		if (!String.isEmpty(jsonString)) {
			jsonString = jsonString.replaceAll('\"[^\"]*\":null',''); // basic removal of null values
			jsonString = jsonString.replaceAll(',{2,}', ','); // remove duplicate/multiple commas
			jsonString = jsonString.replace('{,', '{'); // prevent opening brace from having a comma after it
			jsonString = jsonString.replace(',}', '}'); // prevent closing brace from having a comma before it
			jsonString = jsonString.replace('[,', '['); // prevent opening bracket from having a comma after it
			jsonString = jsonString.replace(',]', ']'); // prevent closing bracket from having a comma before it
		}
		return jsonString;
	}

	public static Long getUnixEpochTime(DateTime dt) {
	   return (dt == null ? null : (dt.getTime() / 1000));
	}

	public static String urlEncode(String str) {
		return (str == null ? null : EncodingUtil.urlEncode(str, 'UTF-8'));
	}

    public static String toCSV(List<Long> longs) {
		String csv = '';
		if (longs != null && !longs.isEmpty()) {
			for (Long l : longs) { csv += l + ','; }
			csv = csv.removeEnd(',');
		}
		return csv;
	}

	public static String toCSV(Set<Long> longs) {
		String csv = '';
		if (longs != null && !longs.isEmpty()) {
			for (Long l : longs) { csv += l + ','; }
			csv = csv.removeEnd(',');
		}
		return csv;
	}

	public static String toCSV(Set<String> strings) {
		String csv = '';
		if (strings != null && !strings.isEmpty()) {
			for (String str : strings) { csv += str + ','; }
			csv = csv.removeEnd(',');
		}
		return csv;
	}

	/*
	// A custom JSON serializer that strips out fields with NULL values from the resulting JSON
	// Hopefully Salesforce will add support to allow this to be done natively at some point
	// If you do need specific fields with NULL values to remain in the JSON then add the names
	// of those fields to the fieldsToNull set.
	// NOTE that this only looks at fields 1 level down from the top
	public static String serializeJsonNoNulls(Object obj) {
		return serializeJsonNoNulls(obj, null);
	}

	public static String serializeJsonNoNulls(Object obj, Set<String> fieldsToNull) {
		if (obj == null) { throw new ZendeskException('obj parameter cannot be null'); }

		Map<String, Object> fieldsMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
		System.debug('**fieldsMap=' + fieldsMap);
		Map<String, Object> updateMap = new Map<String, Object>();
		for (String key : fieldsMap.keySet()) {
			System.debug('**[' + key + '] = ' + fieldsMap.get(key));
			// Only keep items that have a non-null value
			// or that have been specified in the fieldsToNull set
			if (fieldsMap.get(key) != null || (fieldsToNull != null && fieldsToNull.contains(key))) {
				updateMap.put(key, fieldsMap.get(key));
			}
		}

		String updateJson = JSON.serialize(updateMap);
		System.debug('**updateJson=' + updateJson);

		return updateJson;
	}
	*/

}
