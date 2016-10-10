global class ZendeskJobStatusWrapper {

    global ZendeskTypes.ZJobStatus job_status {get;set;}
    global List<ZendeskTypes.ZJobStatus> job_statuses {get;set;}
    private static String jsonString;

    global static ZendeskJobStatusWrapper parse(String json) {
        if (json != null && String.isNotBlank(json)) {
            jsonString = json;
            return new ZendeskJobStatusWrapper(System.JSON.createParser(jsonString));
        }

        return null;
    }

    global ZendeskJobStatusWrapper(JSONParser parser) {
        job_statuses = new List<ZendeskTypes.ZJobStatus>();

        if (parser != null) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'job_status') {
                            job_status = new ZendeskTypes.ZJobStatus(parser);
                        }
                        // Handle an array of Job Statuses (which could each also include an array of Job Status Results objects)
                        else if (text == 'job_statuses' && jsonString != null && String.isNotBlank(jsonString)) {
                            // Deserialize so that we can obtain the map of Job Status results
                            Map<String, Object> tempMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

                            if (tempMap != null && !tempMap.isEmpty()) {
                                List<Object> statusObjList = (List<Object>)tempMap.get('job_statuses');

                                if (statusObjList != null && !statusObjList.isEmpty()) {
                                    for (Object o: statusObjList) {
                                        job_statuses.add(new ZendeskTypes.ZJobStatus(JSON.createParser(JSON.serialize(o))));
                                    }
                                }
                            }
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                            //consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
}
