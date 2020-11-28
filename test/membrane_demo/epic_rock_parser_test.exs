defmodule MembraneDemoWeb.EpicRockParserTest do
  use ExUnit.Case, async: false

  describe "parse_meta/1" do
    test "parses regular songs" do
      meta =
        "StreamTitle='Symphony X - Rediscovery, Pt. 2: The New Mythology';StreamUrl='&artist=Symphony%20X&title=Rediscovery%2C%20Pt.%202%3A%20The%20New%20Mythology&album=V%3A%20The%20New%20Mythology%20Suite&duration=721053&songtype=S&overlay=no&buycd=&website=&picture=SymphonyX-VTheNewMythologySuite.jpg';"

      assert Epic.parse_meta(meta) ==
               %{
                 "album" => "V: The New Mythology Suite",
                 "artist" => "Symphony X",
                 "buycd" => "",
                 "duration" => "721053",
                 "overlay" => "no",
                 "picture" => "SymphonyX-VTheNewMythologySuite.jpg'",
                 "songtype" => "S",
                 "title" => "Rediscovery, Pt. 2: The New Mythology",
                 "website" => ""
               }
    end

    test "parses sweepers" do
      meta =
        "StreamTitle='ID/PSA - ERR Sweeper 17 - NewAndImproved - Jason Cooper';StreamUrl='&artist=ID%2FPSA&title=ERR%20Sweeper%2017%20-%20NewAndImproved%20-%20Jason%20Cooper&album=ID%2FPSA&duration=13740&songtype=I&overlay=yes&buycd=&website=&picture=ERR-Logo.jpg';"

      assert Epic.parse_meta(meta) == %{
               "album" => "ID/PSA",
               "artist" => "ID/PSA",
               "buycd" => "",
               "duration" => "13740",
               "overlay" => "yes",
               "picture" => "ERR-Logo.jpg'",
               "songtype" => "I",
               "title" => "ERR Sweeper 17 - NewAndImproved - Jason Cooper",
               "website" => ""
             }
    end
  end
end
