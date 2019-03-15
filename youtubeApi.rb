require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/youtube_v3'

/*キータからパクりました*/

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'idolsongplaylist'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "tokens.yaml")
SCOPE = [ "https://www.googleapis.com/auth/youtube" ]

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' +
         'resulting code after authorization'
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

YT = Google::Apis::YoutubeV3
youtube = YT::YouTubeService.new
youtube.client_options.application_name = APPLICATION_NAME
youtube.authorization = authorize

optinons = {
  :playlist_id => 'your youtube Library ID',
  :max_results => 2
}
response = youtube.list_playlist_items("snippet", optinons)
pp response
