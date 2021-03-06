require 'test_helper'
class MarcxmlTest < MiniTest::Test

  VALID_MARCXML_PATH        = 'test/fixtures/marcxml/valid'
  INVALID_001_PATH          = 'test/fixtures/marcxml/invalid_001'
  INVALID_003_PATH          = 'test/fixtures/marcxml/invalid_003'
  UNRECOGNIZED_003_PATH     = 'test/fixtures/marcxml/unrecognized_003'
  VALID_DEFAULT_NS_PATH     = 'test/fixtures/marcxml/default_ns'
  VALID_NON_DEFAULT_NS_PATH = 'test/fixtures/marcxml/non_default_ns'
  EMPTY_MARCXML_PATH        = 'test/fixtures/marcxml/empty'
  DNE_MARCXML_PATH          = 'this/path/does/not/exist'
  UNREADABLE_MARCXML_PATH   = 'test/fixtures/marcxml/unreadable'
  BADLY_FORMED_XML_PATH     = 'test/fixtures/marcxml/badly_formed'
  MISSING_050               = 'test/fixtures/marcxml/missing_050'
  MISSING_090               = 'test/fixtures/marcxml/missing_090'
  HAS_050_090               = 'test/fixtures/marcxml/has_050_090'

  # restore read/write permissions on test file
  def teardown
    File.chmod( 0644, UNREADABLE_MARCXML_PATH)
  end

  def test_class
    assert_instance_of(Marcxml, Marcxml.new(VALID_MARCXML_PATH))
  end

  def test_empty_marcxml_file
    assert_raises(Nokogiri::XML::SyntaxError) { Marcxml.new(EMPTY_MARCXML_PATH) }
  end

  def test_nonexistent_marcxml_file
    err = assert_raises(RuntimeError) { Marcxml.new(DNE_MARCXML_PATH) }
    assert_match(/marcxml file does not exist/, err.message)
  end

  def test_unreadable_marcxml_file
    File.chmod( 0000, UNREADABLE_MARCXML_PATH)
    err = assert_raises(RuntimeError) { Marcxml.new(UNREADABLE_MARCXML_PATH) }
    assert_match(/marcxml file is not readable/, err.message)
  end

  def test_marcxml_get_001
    h = Marcxml.new(VALID_MARCXML_PATH)
    assert(h.get_001 == "1621570")
  end

  def test_marcxml_get_003
    h = Marcxml.new(VALID_MARCXML_PATH)
    assert(h.get_003 == "NIC")
  end

  def test_marcxml_missing_003
    err = assert_raises(RuntimeError) { Marcxml.new(INVALID_003_PATH) }
    assert_match(/missing controlfield 003/, err.message)
  end

  def test_marcxml_unrecognized_003
    err = assert_raises(RuntimeError) { Marcxml.new(UNRECOGNIZED_003_PATH) }
    assert_match(/unrecognized controlfield 003/, err.message)
  end

  def test_marcxml_missing_001
    err = assert_raises(RuntimeError) { Marcxml.new(INVALID_001_PATH) }
    assert_match(/missing controlfield 001/, err.message)
  end

  def test_marcxml_get_050
    h = Marcxml.new(HAS_050_090)
    assert(h.get_050 == "\n    BP 160\n    .I13 T26 1951\n  ")
  end

  def test_marcxml_050_empty
    h = Marcxml.new(MISSING_050)
    assert(h.is_050_empty?)
  end

  def test_marcxml_050_not_empty
    h = Marcxml.new(HAS_050_090)
    refute(h.is_050_empty?)
  end

  def test_marcxml_get_090
    h = Marcxml.new(HAS_050_090)
    assert(h.get_090 == "\n    BP160\n    .I25\n  ")
  end

  def test_marcxml_090_empty
    h = Marcxml.new(MISSING_090)
    assert(h.is_090_empty?)
  end

  def test_marcxml_090_not_empty
    h = Marcxml.new(HAS_050_090)
    refute(h.is_090_empty?)
  end

  def test_marcxml_with_namespace
    h = Marcxml.new(VALID_DEFAULT_NS_PATH)
    assert(h.get_003 == "NIC")
    assert(h.get_001 == "1621570")
  end

  def test_marcxml_with_default_namespace
    h = Marcxml.new(VALID_NON_DEFAULT_NS_PATH)
    assert(h.get_003 == "NNU")
    assert(h.get_001 == "001696991")
  end

  def test_badly_formed_xml
    assert_raises(Nokogiri::XML::SyntaxError) { Marcxml.new(BADLY_FORMED_XML_PATH) }
  end
end
