puts "Marketing: SEO"

# Landing Page
generate(:controller, "static index")
route "root to: 'static#index'"
git add: "."
git commit: "-a -m 'Landing Page'"

# SEO
run "touch app/views/layouts/_seo.haml"
inject_into_file "app/views/layouts/_seo.haml" do <<~EOF
  %title= meta_title
  %meta{name:"description", content:"\#{meta_description}"}

  %link{href:  "/seo/apple-icon-57x57.png", rel:  "apple-touch-icon", sizes:  "57x57"}
  %link{href:  "/seo/apple-icon-60x60.png", rel:  "apple-touch-icon", sizes:  "60x60"}
  %link{href:  "/seo/apple-icon-72x72.png", rel:  "apple-touch-icon", sizes:  "72x72"}
  %link{href:  "/seo/apple-icon-76x76.png", rel:  "apple-touch-icon", sizes:  "76x76"}
  %link{href:  "/seo/apple-icon-114x114.png", rel:  "apple-touch-icon", sizes:  "114x114"}
  %link{href:  "/seo/apple-icon-120x120.png", rel:  "apple-touch-icon", sizes:  "120x120"}
  %link{href:  "/seo/apple-icon-144x144.png", rel:  "apple-touch-icon", sizes:  "144x144"}
  %link{href:  "/seo/apple-icon-152x152.png", rel:  "apple-touch-icon", sizes:  "152x152"}
  %link{href:  "/seo/apple-icon-180x180.png", rel:  "apple-touch-icon", sizes:  "180x180"}
  %link{href:  "/seo/android-icon-192x192.png", rel:  "icon", sizes:  "192x192", type:  "image/png"}
  %link{href:  "/seo/favicon-32x32.png", rel:  "icon", sizes:  "32x32", type:  "image/png"}
  %link{href:  "/seo/favicon-96x96.png", rel:  "icon", sizes:  "96x96", type:  "image/png"}
  %link{href:  "/seo/favicon-16x16.png", rel:  "icon", sizes:  "16x16", type:  "image/png"}
  %link{href:  "/seo/manifest.json", rel:  "manifest"}
  %meta{content:  "#ffffff", name:  "msapplication-TileColor"}
  %meta{content:  "/seo/ms-icon-144x144.png", name:  "msapplication-TileImage"}
  %meta{content:  "#ffffff", name:  "theme-color"}

  -# Facebook Open Graph data
  %meta{property:"og:title", content:"\#{meta_title}"}
  %meta{property:"og:type", content:"website"}
  %meta{property:"og:url", content:"\#{request.original_url}"}
  %meta{property:"og:image", content:"\#{meta_image}"}
  %meta{property:"og:image:width", content:"681"}
  %meta{property:"og:image:height", content:"682"}
  %meta{property:"og:description", content:"\#{meta_description}"}
  %meta{property:"og:site_name", content:"\#{meta_title}"}

  -# Twitter Card data
  %meta{name:"twitter:card", content:"summary_large_image"}
  %meta{name:"twitter:site", content:"\#{meta_title}"}
  %meta{name:"twitter:title", content:"\#{meta_title}"}
  %meta{name:"twitter:description", content:"\#{meta_description}"}
  %meta{name:"twitter:image:src", content:"\#{meta_image}"}

  -# Google Item Scope
  %meta{ itemscope: "", itemtype: "http://schema.org/Article" }
  %meta{ itemprop: "name", content:"\#{meta_title}" }
  %meta{ itemprop: "description", content:"\#{meta_description}" }
  %meta{ itemprop: "title", content: "\#{meta_title}" }
  %meta{ itemprop: "image", content: "\#{meta_image}" }
  EOF
end


run "touch app/helpers/meta_tags_helper.rb"

inject_into_file "app/helpers/meta_tags_helper.rb" do <<~EOF
  module MetaTagsHelper
    def meta_title
      content_for(:seo_meta_title) || "DEFAULT TITLE"
    end

    def meta_description
      content_for(:seo_meta_description) || "DEFAULT DESCRIPTION"
    end

    def meta_image
      # Placed in public folder
      content_for(:seo_meta_image) || "\#{ENV["SITE_URL"]}/seo/meta_image.png"
    end
  end
  EOF
end

gsub_file "app/views/layouts/application.html.haml", /(.*%title .*)/, "    = render 'layouts/seo'"

git add: "."
git commit: "-m 'SEO config'"