require 'fileutils'

inputYear = ARGV[0]

unless inputYear.match(/^\d{4}$/)
  puts "Please enter a valid year for download"
  puts "Example: insider-capture.rb 2019"
  exit
end

TempDir = "./tempdir"
OutputDir = "./WSU-Insiders_#{inputYear}"
PDFDir = "#{OutputDir}/PDFs"
WARCDir = PdfDir = "#{OutputDir}/WARCs"

#initial download for directory/name structure
FileUtils.mkdir(TempDir)
FileUtils.mkdir(OutputDir)
FileUtils.mkdir(PDFDir)
FileUtils.mkdir(WARCDir)

months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
months.each do |month|
  FileUtils.mkdir("#{WARCDir}/#{month}")
  FileUtils.mkdir("#{PDFDir}/#{month}")
  FileUtils.chdir(TempDir)
  downloadCommand = "wget -r -np https://news.wsu.edu/#{inputYear}/#{month}/"
  system(downloadCommand)
  FileUtils.chdir('..')
  FileUtils.pwd
  targetArticles = Dir.glob("#{TempDir}/news.wsu.edu/#{inputYear}/#{month}/**/*.html")
  targetArticles.each do |article|
    article_location = File.dirname(article)
    article_name = File.basename(article_location)
    web_address = 'https://news.wsu.edu' + article_location.split('news.wsu.edu')[1]
    pdf_out = "#{OutputDir}/PDFs/#{month}/#{article_name}.pdf"
    warc_out = "#{OutputDir}/WARCs/#{month}/#{article_name}"
    warc_command = "wget #{web_address} --delete-after --no-directories --timeout 1 -p -k -H -D 'news.wsu.edu,repo.wsu.edu,s3.wp.wsu.edu' --warc-file=#{warc_out}"
    pdf_command = "google-chrome --headless --print-to-pdf=#{pdf_out} #{web_address}"
    puts article_name
    `#{pdf_command}`
    `#{warc_command}`
  end
end

FileUtils.rm_rf(TempDir)