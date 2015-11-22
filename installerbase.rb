
require 'FileUtils'

def get_texmflocal_dir
  command = "kpsewhich -var-value TEXMFLOCAL"
  texmflocal = ""
  begin
    texmflocal = `#{command}`.chomp
  rescue
    puts "cannot get TEXMFLOCAL dir (kpsewhich failed)"
    puts "type your texmflocal dir: "
    texmflocal = gets.chomp
  end
  texmflocal
end

def init_directories(texmflocal)
  Dir.mkdir(texmflocal + "/fonts")      if !Dir.exists?(texmflocal + "/fonts")
  Dir.mkdir(texmflocal + "/fonts/tfm")  if !Dir.exists?(texmflocal + "/fonts/tfm")
  Dir.mkdir(texmflocal + "/fonts/vf")   if !Dir.exists?(texmflocal + "/fonts/vf")
  Dir.mkdir(texmflocal + "/fonts/map")  if !Dir.exists?(texmflocal + "/fonts/map")
  Dir.mkdir(texmflocal + "/fonts/map/dvipdfmx") if !Dir.exists?(texmflocal + "/fonts/map/dvipdfmx")
  Dir.mkdir(texmflocal + "/fonts/enc")      if !Dir.exists?(texmflocal + "/fonts/enc")
  Dir.mkdir(texmflocal + "/fonts/opentype") if !Dir.exists?(texmflocal + "/fonts/opentype")
  Dir.mkdir(texmflocal + "/tex")            if !Dir.exists?(texmflocal + "/tex")
  Dir.mkdir(texmflocal + "/tex/latex")      if !Dir.exists?(texmflocal + "/tex/latex")
  Dir.mkdir(texmflocal + "/tex/latex/fd")   if !Dir.exists?(texmflocal + "/tex/latex/fd")
end

def install(texmflocal)
  # move to package/ directory
  Dir.chdir(File.expand_path(File.dirname(__FILE__)))
  Dir.chdir("../package")
  
  FileUtils.copy(MAPFILES, texmflocal + "/fonts/map/dvipdfmx")
  FileUtils.copy(TFMFILES, texmflocal + "/fonts/tfm")
  FileUtils.copy(VFFILES,  texmflocal + "/fonts/vf")
  FileUtils.copy(ENCFILES, texmflocal + "/fonts/enc")
  FileUtils.copy(FDFILES,  texmflocal + "/tex/latex/fd")
end

def uninstall(texmflocal)
  # move to package/ directory
  Dir.chdir(File.expand_path(File.dirname(__FILE__)))
  Dir.chdir("../package")

  MAPFILES.each do |f|
    FileUtils.remove(texmflocal + "/fonts/map/dvipdfmx/" + File.basename(f))
  end
  TFMFILES.each do |f|
    FileUtils.remove(texmflocal + "/fonts/tfm/" + File.basename(f))
  end
  VFFILES.each do |f|
    FileUtils.remove(texmflocal + "/fonts/vf/" + File.basename(f))
  end
  ENCFILES.each do |f|
    FileUtils.remove(texmflocal + "/fonts/enc/" + File.basename(f))
  end
  FDFILES.each do |f|
    FileUtils.remove(texmflocal + "/tex/latex/fd/" + File.basename(f))
  end
end

def main
  texmflocal = get_texmflocal_dir
  init_directories(texmflocal)
  if ARGV.length == 0 || ARGV[0] == "install"
    install(texmflocal)
  elsif ARGV[0] == "uninstall"
    uninstall(texmflocal)
  else
    puts "Usage: ruby #{$0} [install/uninstall]"
  end
end

main
