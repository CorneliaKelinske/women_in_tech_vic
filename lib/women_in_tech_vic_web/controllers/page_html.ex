defmodule WomenInTechVicWeb.PageHTML do
  use WomenInTechVicWeb, :html
  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1]

  embed_templates "page_html/*"
end
