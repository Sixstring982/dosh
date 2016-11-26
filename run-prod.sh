MIX_ENV=prod brunch build --production
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix compile.protocols
MIX_ENV=prod PORT=4000 elixir -pa _build/prod/consolidated -S mix phoenix.server
