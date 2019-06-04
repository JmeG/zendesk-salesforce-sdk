global abstract class ZendeskResourceBase extends ZendeskTypes {

    protected final ZendeskConnection zconn;

    protected final String HTTP_GET = 'GET';
    protected final String HTTP_POST = 'POST';
    protected final String HTTP_PUT = 'PUT';
    protected final String HTTP_DELETE = 'DELETE';


    global ZendeskResourceBase(ZendeskConnection zconn) {
        this.zconn = zconn;
        if (zconn == null) { throw new ZendeskException('ZendeskConnection is null'); }
    }

    // replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
    // Note that a full list of reserved words can be found here
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_reserved_words.htm
    protected String replaceReservedWords(String str) {
        str = str.replaceAll('"default"\\s*:', '"x_default":');
        str = str.replaceAll('"group"\\s*:', '"x_group":');
        str = str.replaceAll('"system"\\s*:', '"x_system":');
        str = str.replaceAll('"public"\\s*:', '"x_public":');
        return str;
    }

    // un-replace reserved keywords in the JSON string
    // Use when calling serialize()
    protected String unreplaceReservedWords(String str) {
        str = str.replaceAll('"x_default"\\s*:', '"default":');
        str = str.replaceAll('"x_group"\\s*:', '"group":');
        str = str.replaceAll('"x_system"\\s*:', '"system":');
        str = str.replaceAll('"x_public"\\s*:', '"public":');
        return str;
    }

    // // Hacky way of stripping out nulls.
    // // https://iwritecrappycode.wordpress.com/2014/07/16/stripping-nulls-from-a-json-object-in-apex/
    // // This is now replaced with JSON.serialize(object, suppressApexObjectNulls=true);
    // global static string stripJsonNulls(String jsonString) {
    //     if (!String.isEmpty(jsonString)) {
    //         jsonString = jsonString.replaceAll('\"[^\"]*\":null',''); // basic removal of null values
    //         jsonString = jsonString.replaceAll(',{2,}', ','); // remove duplicate/multiple commas
    //         jsonString = jsonString.replace('{,', '{'); // prevent opening brace from having a comma after it
    //         jsonString = jsonString.replace(',}', '}'); // prevent closing brace from having a comma before it
    //         jsonString = jsonString.replace('[,', '['); // prevent opening bracket from having a comma after it
    //         jsonString = jsonString.replace(',]', ']'); // prevent closing bracket from having a comma before it
    //     }
    //     return jsonString;
    // }

    global static Long getUnixEpochTime(DateTime dt) {
       return (dt == null ? null : (dt.getTime() / 1000));
    }

    global static String urlEncode(String str) {
        return (str == null ? null : EncodingUtil.urlEncode(str, 'UTF-8'));
    }

    global static String toCSV(List<Long> longs) {
        String csv = '';
        if (longs != null && !longs.isEmpty()) {
            for (Long l : longs) { csv += l + ','; }
            csv = csv.removeEnd(',');
        }
        return csv;
    }

    global static String toCSV(Set<Long> longs) {
        String csv = '';
        if (longs != null && !longs.isEmpty()) {
            for (Long l : longs) { csv += l + ','; }
            csv = csv.removeEnd(',');
        }
        return csv;
    }

    global static String toCSV(Set<String> strings) {
        String csv = '';
        if (strings != null && !strings.isEmpty()) {
            for (String str : strings) { csv += str + ','; }
            csv = csv.removeEnd(',');
        }
        return csv;
    }
}
