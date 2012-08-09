module Olympics
  class << (Analysis = Object.new)
    attr_accessor :r

    # Does a two-sided Pearson correlation.
    #
    # Accepts a hash with x and y datasets
    # Returns a hash with n, r, and p values
    def correlation(params)
      r.assign("x", x=params.fetch(:x))
      r.assign("y", y=params.fetch(:y))

      data = r.eval_R %{ cor.test(x, y) }

      { :n => x.size, :r => data["estimate"]["cor"], :p => data["p.value"] }
    end

    # Creates a 400x400 pixel scatterplot in PNG format
    # 
    # Accepts a hash with file, x, y, x_label, and y_label parameters
    # Writes image to file and returns nil
    def plot(params)
      [:file, :x, :y, :x_label, :y_label].each do |key|
        r.assign(key.to_s, params.fetch(key))
      end

      r.eval_R %{
        jpeg(filename=file, width=400, height=400)
        plot(x=x, y=y, xlab=x_label, ylab=y_label)
        abline(lm(y ~ x), col="red")
        dev.off()
      }

      nil
    end
  end
end

require "rsruby"




Olympics::Analysis.r = RSRuby.instance

p Olympics::Analysis.correlation(:x => [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1], :y => (1..20).to_a)
