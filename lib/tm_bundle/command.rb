# params[:a] = true   # -a
# params[:b] = "1"    # -b1
# params[:foo] = "1"  # --foo
# params[:bar] = "x"  # --bar x
# params[:zot] = "z"  # --zot Z

def start
  TMBundle.eager_load!
  @tmb = TMBundle.new
  yield
end

case ARGV.shift
when "fix-names"
  start {@tmb.fix_names!}
when "menu" 
  case ARGV.shift
  when "export"
    params = ARGV.getopts("fp:")
    prefix = params['p'] || Time.now.to_formatted_s(:number) unless params['f']
    start{
      p params            
      @tmb.menu_export!(prefix)
    }
  when "apply"
    start {
      params = ARGV.getopts("v:", "last")
      type = params['last'] || params['v']
      @tmb.save_plist! type
    }
  else
    puts " (export,apply)"
  end
else
  puts " (fix-names,menu)"
end