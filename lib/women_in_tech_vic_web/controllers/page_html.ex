defmodule WomenInTechVicWeb.PageHTML do
  use WomenInTechVicWeb, :html
  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  embed_templates "page_html/*"
end
