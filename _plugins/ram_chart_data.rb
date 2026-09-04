require "yaml"

module Jekyll
  class RamChartDataGenerator < Generator
    priority :highest

    def generate(site)
      chart_path = File.join(site.source, "helm", "sas-retrieval-agent-manager", "Chart.yaml")
      chart = YAML.safe_load_file(chart_path)
      site.data["ram_chart"] = { "version" => chart.fetch("version") }
    end
  end
end