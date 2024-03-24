#!/usr/bin/env ruby
#coding: binary

GARBAGE_RE = %r!(?:\n|\A)(?:-{2,}|/{2,})[A-Z0-9]+$!

def remove_garbage(data)
  # remove most of grabage
  data.gsub!("\r\n", "\n")
  data.gsub!(GARBAGE_RE, '')

  # remove last line that may have been patched to get the 0x1A2F checksum
  dcut = data[0..-2]
  dcut1 = dcut.sub(GARBAGE_RE, '')
  dcut == dcut1 ? data : dcut1
end

def decrypt(data)
  key = 173
  data.size.times do |i|
    data[i] = (((data[i].ord ^ (key%127)) - 1) & 0xff).chr
    key += 13
  end
  data
end

def decrypt_dirs(dirs)
  require 'fileutils'
  dirs.each do |dir|
    outdir = "#{dir}_decrypted"
    puts "[.] Decrypting #{dir} into #{outdir}"
    Dir["#{dir}/**/*.{enl,otmod,otui}"].each do |fname|
      data = File.binread(fname)
      outfname = File.join(outdir, fname[dir.size+1..-1]).sub(/\.enl\z/, '.lua')
      FileUtils.mkdir_p(File.dirname(outfname))
      File.binwrite(outfname, remove_garbage(decrypt(data)))
    end
  end
end

def decrypt_files(files)
  files.each do |fname|
    data = File.binread(fname)
    puts remove_garbage(decrypt(data))
  end
end

if $0 == __FILE__
  if ARGV.empty?
    puts "Usage1: #{$0} <file1> <file2> ..."
    puts "Usage2: #{$0} -d <dir1> <dir22> ..."
    exit 1
  end
  if ARGV.delete('-d')
    decrypt_dirs(ARGV)
  else
    decrypt_files(ARGV)
  end
end
