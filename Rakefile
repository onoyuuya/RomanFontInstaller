require 'json'
#require 'FileUtils'

def mapconvert(mapfilein, family, slant)
  fin = File.open(mapfilein, "r")
  fout = File.open(family + ".map", "w")
  while (l = fin.gets)
    next if !(l.start_with?(family))
    l.sub!(/ReEncodeFont" <\[/, "")
    l.sub!(/</, "")
    items = l.split(" ")
    if l.include?("SlantFont")
      line = sprintf("%s %s %s -s %s\n",
              items[0], items[5].sub(/a_/, family + "_"), items[6], slant)
    else
      line = sprintf("%s %s %s\n",
              items[0], items[3].sub(/a_/, family + "_"), items[4])
    end
    fout.write(line)
  end
  fin.close
  fout.close
end

def packaging(fs)
  family = fs["family"]
  # packaging
  Dir.glob("*.enc").each do |f|
    FileUtils.move(f, f.sub(/a_/, family + "_"))
  end
  encfiles = Dir.glob("*.enc")
  tfmfiles = Dir.glob("*.tfm")
  vffiles  = Dir.glob("*.vf")
  fdfiles  = Dir.glob("*.fd")
  mapfiles = Dir.glob("*.map")
  FileUtils.move(encfiles, "package/enc/")
  FileUtils.move(tfmfiles, "package/tfm/")
  FileUtils.move(vffiles,  "package/vf/")
  FileUtils.move(fdfiles,  "package/fd/")
  FileUtils.move(mapfiles, "package/map/")

  filelists = "ENCFILES = ["
  encfiles.each  {|f| filelists += "\"enc/" + f + "\", "}
  filelists.chop!.chop!
  filelists += "]\n"
  filelists += "TFMFILES = ["
  tfmfiles.each  {|f| filelists += "\"tfm/" + f + "\", "}
  filelists.chop!.chop!
  filelists += "]\n"
  filelists += "VFFILES = ["
  vffiles.each  {|f| filelists += "\"vf/" + f + "\", "}
  filelists.chop!.chop!
  filelists += "]\n"
  filelists += "FDFILES = ["
  fdfiles.each  {|f| filelists += "\"fd/" + f + "\", "}
  filelists.chop!.chop!
  filelists += "]\n"
  filelists += "MAPFILES = ["
  mapfiles.each  {|f| filelists += "\"map/" + f + "\", "}
  filelists.chop!.chop!
  filelists += "]\n"
  installer_str = filelists + File.read("installerbase.rb")
  File.write("installers/" + family + "_installer.rb", installer_str)
end

def installer_generator(fs)
  slant = "0.167"
  tempmapfile = "__temp.map"
  encfile = ["ec.enc", "q-ts1-uni.enc"]
  family = fs["family"]
  shapes = fs["shapes"]
  
  ["T1", "TS1"].each_with_index do |encoding,i|
    fdstr = sprintf("\\DeclareFontFamily{%s}{%s}{}\n", encoding, family)
    shapes.each do |shape|
      if shape["ssub"] != nil
        fdstr += sprintf("\\DeclareFontShape{%s}{%s}{%s}{%s}{<->ssub*%s/%s/%s}{}\n",
                         encoding, family, shape["weight"], shape["shape"],
                         family, shape["ssub"]["weight"], shape["ssub"]["shape"])
      else
        tfmname = sprintf("%s-%s-%s", family, shape["tfmname"], encoding.downcase)
        fdstr += sprintf("\\DeclareFontShape{%s}{%s}{%s}{%s}{<->%s}{}\n",
                         encoding, family, shape["weight"], shape["shape"], tfmname)
        slantopt = (shape["slanted"]) ? "-S " + slant : ""
        options  = "--no-type1 --no-dotlessj --no-updmap -f kern -f liga "
        options += sprintf("--mapfile=%s %s -e %s -n %s opentype/%s",
                          tempmapfile, slantopt, encfile[i], tfmname, shape["fontfile"])
        system "otftotfm " + options
      end
    end
    File.write(encoding.downcase + family + ".fd", fdstr)
  end
  mapconvert(tempmapfile, family, slant)
  File.delete(tempmapfile)

  packaging(fs)
end

desc "default task is 'help'"
task :default => [:help]

desc "print this"
task :help do
  system "rake -T"
end

desc "make directory structures"
task :initdirs do
  Dir.mkdir("package")          if !Dir.exists?("package")
  Dir.mkdir("package/tfm")      if !Dir.exists?("package/tfm")
  Dir.mkdir("package/vf")       if !Dir.exists?("package/vf")
  Dir.mkdir("package/fd")       if !Dir.exists?("package/fd")
  Dir.mkdir("package/map")      if !Dir.exists?("package/map")
  Dir.mkdir("package/enc")      if !Dir.exists?("package/enc")
  Dir.mkdir("installers")       if !Dir.exists?("installers")
  Dir.mkdir("settings")         if !Dir.exists?("settings")
  Dir.mkdir("opentype")         if !Dir.exists?("opentype")
end

desc "generate fd, tfm, vf, enc, map files according to settings/"
task :generate => [:initdirs] do
  existing_installers = Dir.glob("installers/*").map {|f| File.basename(f)}
  Dir.glob("settings/*").each do |fsname|
    fs = JSON.parse(File.read(fsname))
    family = fs["family"]
    if existing_installers.index(family + "_installer.rb") != nil
      puts family + " installer is already exists."
      next
    end
    installer_generator(fs)
  end
end

desc "install font files into $TEXMFLOCAL"
task :install do
  Dir.glob("installers/*").each do |f|
    system "ruby " + f
  end
end
