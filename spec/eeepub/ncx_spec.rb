require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'tmpdir'
require 'fileutils'

describe "EeePub::NCX" do
  before do
    @ncx = EeePub::NCX.new(
      :uid => 'uid',
      :nav_map => [
        {:label => 'foo', :content => 'foo.html'},
        {:label => 'bar', :content => 'bar.html'}
      ]
    )
  end

  it 'should set default values' do
    @ncx.depth.should == 1
    @ncx.total_page_count.should == 0
    @ncx.max_page_number.should == 0
    @ncx.doc_title.should == 'Untitled'
  end

  it 'should make xml' do
    doc  = Nokogiri::XML(@ncx.to_xml)
    head = doc.at('head')
    head.should_not be_nil

    head.at("//xmlns:meta[@name='dtb:uid']")['content'].should == @ncx.uid
    head.at("//xmlns:meta[@name='dtb:depth']")['content'].should == @ncx.depth.to_s
    head.at("//xmlns:meta[@name='dtb:totalPageCount']")['content'].should == @ncx.total_page_count.to_s
    head.at("//xmlns:meta[@name='dtb:maxPageNumber']")['content'].should == @ncx.max_page_number.to_s
    head.at("//xmlns:docTitle/xmlns:text").inner_text.should == @ncx.doc_title

    nav_map = doc.at('navMap')
    nav_map.should_not be_nil
    nav_map.search('navPoint').each_with_index do |nav_point, index|
      expect = @ncx.nav_map[index]
      nav_point.attribute('id').value.should == "navPoint-#{index + 1}"
      nav_point.attribute('playOrder').value.should == (index + 1).to_s
      nav_point.at('navLabel').at('text').inner_text.should == expect[:label]
      nav_point.at('content').attribute('src').value.should == expect[:content]
    end
  end

  context 'nested nav_map' do
    before do
      @ncx.nav = [
        {:label => 'foo', :content => 'foo.html',
          :nav => [
            {:label => 'foo-1', :content => 'foo-1.html'},
            {:label => 'foo-2', :content => 'foo-2.html'}
          ],
        },
        {:label => 'bar', :content => 'bar.html'}
      ]
    end

    it 'should make xml' do
      doc  = Nokogiri::XML(@ncx.to_xml)
      nav_map = doc.at('navMap')

      nav_map.search('navMap/navPoint').each_with_index do |nav_point, index|
        expect = @ncx.nav_map[index]
        nav_point.attribute('id').value.should == "navPoint-#{index + 1}"
        nav_point.attribute('playOrder').value.should == (index + 1).to_s
        nav_point.at('navLabel').at('text').inner_text.should == expect[:label]
        nav_point.at('content').attribute('src').value.should == expect[:content]
      end

      nav_map.search('navPoint/navPoint').each_with_index do |nav_point, index|
        expect = @ncx.nav[0][:nav][index]
        nav_point.attribute('id').value.should == "navPoint-#{index + 2}"
        nav_point.attribute('playOrder').value.should == (index + 2).to_s
        nav_point.at('navLabel').at('text').inner_text.should == expect[:label]
        nav_point.at('content').attribute('src').value.should == expect[:content]
      end
    end
  end
end
