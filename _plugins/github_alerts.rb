# Converts GitHub-style alert blockquotes (e.g. "> [!CAUTION]") into just-the-docs
# callouts at build time, so the same Markdown renders natively on GitHub and as a
# styled callout on the Jekyll site.
module Jekyll
  module GithubAlerts
    ALERT_TYPES = %w[note tip important warning caution].freeze
    MARKER_PATTERN = /<blockquote>\s*<p>\s*\[!(#{ALERT_TYPES.join("|")})\]\s*/i.freeze

    def self.convert(output)
      return output unless output&.include?("[!")

      output.gsub(MARKER_PATTERN) { "<blockquote class=\"#{Regexp.last_match(1).downcase}\">\n<p>" }
    end
  end

  Hooks.register [:documents, :pages], :post_render do |item|
    item.output = GithubAlerts.convert(item.output)
  end
end
