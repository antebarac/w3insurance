# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Sabre_session',
  :secret      => '94bab349ca1c89c3b3eb593cb23be52dba38d83c4b5ae139f9b095eb622189309b1d2767ee34ad1c835ec0d0453d54b9484053ceb20104c89080a22bd3078ef0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
