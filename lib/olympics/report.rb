require_relative "analysis"
require "tempfile"

module Olympics
  class Report
    def initialize(data, document)
      @data      = data
      @document  = document
    end

    def render(title)
      @document.define_grid(:columns => 2, :rows => 1)
      @document.move_down(50)
      @document.text(title, :size => 36, :align => :center)

      @document.grid(0,0).bounding_box do
        @document.move_down(100)

        scatterplot(:x => [:all_medals, "All Medals"],
                    :y => [:gdp, "GDP"])
      end
      
      @document.grid(0,1).bounding_box do
        @document.move_down(100)

        scatterplot(:x => [:all_medals, "All Medals"],
                    :y => [:population, "Population"])
      end

      @document.move_cursor_to(50)

      @document.text "NOTE: GDP is in millions of 1990 "   +
                     "International Geary-Khamis dollars, "+
                     "Population is in thousands of people.", :align => :center
    end

    private

    def correlation_summary(x, y)
      stats = Analysis.correlation(:x => x, :y => y)
      n = "n = #{stats[:n]}"
      r = "r ~= #{'%.3f' % stats[:r]}"
      
      if stats[:p] < 0.001
        p = 'p < 0.001'
      else
        p = "p ~= #{'%.3f' % stats[:p]}"
      end

      [n,r,p].join(", ")
    end

    def scatterplot(params)
      x_key, x_label = params.fetch(:x)
      y_key, y_label = params.fetch(:y)
      
      filename = "#{x_key}_#{y_key}.jpg"

      Dir.chdir(Dir.mktmpdir) do
        Analysis.plot(:x       => @data[x_key],
                      :y       => @data[y_key],
                      :x_label => x_label,
                      :y_label => y_label,
                      :file    => filename)

        @document.image(filename, :scale    => 0.75,
                                  :position => :center)
      end


      summary_text = correlation_summary(@data[x_key], @data[y_key])

      @document.text("#{x_label} vs. #{y_label}", 
                     :align => :center, :size  => 18)
      @document.text(summary_text, :align => :center)
    end
  end
end
