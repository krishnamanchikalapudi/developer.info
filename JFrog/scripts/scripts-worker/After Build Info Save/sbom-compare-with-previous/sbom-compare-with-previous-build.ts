export default async (context: PlatformContext, data: AfterBuildInfoSaveRequest): Promise<AfterBuildInfoSaveResponse> => {
    try {
        // The HTTP client facilitates calls to the JFrog Platform REST APIs
        //To call an external endpoint, use 'await context.clients.axios.get("https://foo.com")'
        const buildName: String = data.build.name; // "spring-petclinic"; // context.secrets.get("buildName"); // "spring-petclinic"
        const slackOauthToken = context.secrets.get('slackOauthToken');  // https://api.slack.com/apps/A08C4PHE8DP/oauth?
        const slackChannel = 'D06U027Q2AU'; // krishnam
        const slackMessageTo = context.secrets.get('slackMessageTo');;

        console.log("buildName: " + JSON.stringify(data));
        // const slackChannel = "C08A18RARTL";   // ansys-ps-internal
        var dateDisplay = new Date(Date.now() - (new Date().getTimezoneOffset() * 1000 * 60)).toJSON().slice(0, 19).replace("T", " ");
        console.log("dateDisplay: " + dateDisplay);
        // console.log("buildName: "+ buildName );
        // console.log("slackToken: "+ slackToken);
        const buildsJson = await context.clients.platformHttp.get("/artifactory/api/build/" + buildName);
        console.log(buildsJson);

        // You should reach this part if the HTTP request status is successful (HTTP Status 399 or lower)
        if (buildsJson.status === 200) {
            // GET last 2 Builds. ref https://jfrog.com/help/r/jfrog-rest-apis/build-runs
            const buildsNumbers = buildsJson.data.buildsNumbers;
            let buildsNumbersLen = buildsNumbers.length;
            console.log("Build numbers lenght: " + buildsNumbersLen);
            let recentBuild: string | null = null;
            let lastBuild: string | null = null;
            console.log("Build numbers >2: " + (buildsNumbersLen >= 2));

            if (buildsNumbersLen > 2) {
                recentBuild = (buildsNumbers[0].uri).substring(1);
                lastBuild = (buildsNumbers[1].uri).substring(1);
            }  // if (buildsNumbers.length > 2)
            console.log("Recent Build: " + recentBuild + "   is empty: " + !isEmpty(recentBuild));
            console.log("lastBuild Build: " + lastBuild + "   is empty: " + !isEmpty(lastBuild));

            if (!isEmpty(recentBuild) && !isEmpty(lastBuild)) {
                // https://jfrog.com/help/r/jfrog-rest-apis/builds-diff
                let diffPathUrl: String = ("/artifactory/api/build/" + buildName + "/" + recentBuild + "?diff=" + lastBuild);
                console.log("Diff Path: " + diffPathUrl);
                const buildDiffJson = await context.clients.platformHttp.get(`${diffPathUrl}`);
                if (buildDiffJson.status === 200) {
                    console.log(buildDiffJson);
                    // Send Slack message to krishna
                    const rawMessageData = buildDiffJson.data == null ? null : extractMessageDataFromPayload(buildDiffJson.data, recentBuild, lastBuild, data);
                    console.log("rawMessageData: " + rawMessageData);

                    await getMemberIdByEmail(context, slackMessageTo, slackOauthToken).then(id => {
                        console.log('Member ID:', id);
                        sendSlackMessage(context, rawMessageData, slackOauthToken, id).catch(console.error);
                    });

                    console.log("sent slack msg");
                } // if (buildDiffJson.status === 200)

                console.log("    ");
                console.log("    ");
            } // if (!isEmpty(recentBuild) && !isEmpty(lastBuild)) 

        } else {
            console.warn(`Request was successful and returned status code : ${buildsJson.status}`);
        } // if (buildsJson.status === 200)
    } catch (error) {
        // The platformHttp client throws PlatformHttpClientError if the HTTP request status is 400 or higher
        console.error(`Request failed with status code ${error.status || "<none>"} caused by : ${error.message}`);
    } // try - catch

    return {
        message: "proceed",
    };
};

function isEmpty(value) {
    return (value == null || (typeof value === "string" && value.trim().length === 0));
}

interface MessageData {
    title: string;
    message: string;
    botName: string;
    url: string;
}

function extractMessageDataFromPayload(payload, recentBuild, lastBuild, data): MessageData | null {
    // console.log(JSON.stringify(payload))
    let msgtext: string = (" * Artifacts count:: New= " + payload.artifacts.new.length + ", Updated= " + payload.artifacts.updated.length + ", Unchanged= " + payload.artifacts.unchanged.length + ", Removed= " + payload.artifacts.removed.length);
    msgtext += (" * Dependencies count:: New= " + payload.dependencies.new.length + ", Updated=" + payload.dependencies.updated.length + ", Unchanged= " + payload.dependencies.unchanged.length + ", Removed= " + payload.dependencies.removed.length);
    msgtext += (" Payload: " + JSON.stringify(data) );
    console.log(msgtext);

    return {
        title: (data.build.name + ' - SBOM Compare between builds: ' + recentBuild + ' and ' + lastBuild),
        message: msgtext,
        // message: "TEXT Sample ",
        botName: 'JFrog Worker Ansys bot',
        url: 'https://psazuse.jfrog.io/ui/login/'
    };
}


async function sendSlackMessage(context: PlatformContext,
    rawMessageData: MessageData, slackToken: string, slackChannel: string): Promise<void> {
    const slackUrl = 'https://slack.com/api/chat.postMessage';
    console.log("Sending Slack message to  " + slackChannel);

    // Replace placeholders in the message template
    const msg = replaceTokens(slackMessageTemplate, rawMessageData);

    console.log('JSON doc: ' + JSON.stringify(msg));
    console.log('JSON doc blocks: ' + JSON.stringify(msg.blocks));
    try {
        const response = await context.clients.axios.post(
            slackUrl,
            {
                channel: slackChannel,
                blocks: getValueFromJSON(msg, 'blocks')
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${slackToken}`,
                },
            }
        );
        console.log("send Slack Message response: " + JSON.stringify(response));
        if (response.data.ok) {
            console.log('Slack: Message sent successfully');
        } else {
            console.error('Slack: Error response message:', response.data.error);
        }   // if (response.data.ok)
    } catch (error) {
        console.error('Slack: Error sending message:', error);
    } // TRY - CATCH
}

function replaceTokens(messageTemplate: any, rawMessageData: MessageData) {
    let hydratedMessage;
    try {
        console.log('Replacing tokens in message template: ' + JSON.stringify(messageTemplate));

        hydratedMessage = JSON.parse(JSON.stringify(messageTemplate)
            .replaceAll('{{MESSAGE_TITLE}}', rawMessageData.title)
            .replaceAll('{{MESSAGE}}', rawMessageData.message)
            .replaceAll('{{BOT_NAME}}', rawMessageData.botName)
            .replaceAll('{{URL}}', rawMessageData.url));

        console.log("hydratedMessage: " + + JSON.stringify(hydratedMessage));

    } catch (error) {
        console.error('Error replacing tokens:', error);
        console.log(hydratedMessage);
    } // TRY-CATCH
    return hydratedMessage;
}
type JSONObject = { [key: string]: any };

const getValueFromJSON = (obj: JSONObject, path: string): any => {
    const keys = path.split('.').map(key => {
        const arrayMatch = key.match(/^(.+)\[(\d+)\]$/);
        if (arrayMatch) {
            return { key: arrayMatch[1], index: parseInt(arrayMatch[2]) };
        }
        return { key, index: null };
    });

    let result: any = obj;

    for (const { key, index } of keys) {
        if (result && typeof result === 'object' && key in result) {
            result = result[key];
            if (index !== null) {
                if (Array.isArray(result) && index < result.length) {
                    result = result[index];
                } else {
                    return undefined;  // Return undefined if index is out of range or not an array
                }
            } // if (index !== null)
        } else {
            return undefined;  // Return undefined if the path is not valid
        }
    } // for (const { key, index } of keys)

    return result;
};


const slackMessageTemplate = {
    blocks: [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*{{MESSAGE_TITLE}}*"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*{{BOT_NAME}}*"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "{{MESSAGE}}"
            }
        },
        {
            "type": "actions",
            "elements": [
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "{{BOT_NAME}}"
                    },
                    "url": "{{URL}}",
                    "action_id": "action_jfrog_platform_prod"
                }
            ]
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": "JFrog Worker bot test message from PS Notifier"
                }
            ]
        }
    ]
}

async function getMemberIdByEmail(context: PlatformContext, email: string, token: string): Promise<string> {
    try {
        const response = await context.clients.axios.get('https://slack.com/api/users.lookupByEmail', {
            headers: {
                Authorization: `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            params: { email }
        });
        console.log("getMemberIdByEmail response: " + JSON.stringify(response));
        const data = response.data;
        if (!data.ok) {
            throw new Error(`Slack API error: ${data.error}`);
        }

        return data.user.id;
    } catch (error) {
        console.error('Error fetching user by email:', error);
        // return null;
    }
}