unit sqldbrestconst;

{$mode objfpc}{$H+}

interface

Resourcestring
  SErrNoconnection = 'Could not determine connection for resource "%s"';
  SErrUnexpectedException = 'An unexpected exception %s occurred with message: %s';
  SErrFieldWithoutRow = 'Attempt to write field %s without active row!';
  SErrUnsupportedRestFieldType = 'Unsupported REST field type : %s';
  SErrDoubleRowStart = 'Starting row within active row';
  SErrMissingParameter = 'No value provided for parameter: "%s"';
  SErrInvalidParam = 'Invalid value for parameter: "%s"';
  SErrFilterParamNotFound = 'Filter parameter for field "%s" not found.';
  SErrResourceNameEmpty = 'Resource Public name is not allowed to be empty.';
  SErrDuplicateResource = 'Duplicate resource name : %s';
  SErrUnknownStatement = 'Unknown kind of statement : %d';
  SErrRegisterUnknownStreamerClass = 'Registering streamer of unknown class: %s';
  SErrUnRegisterUnknownStreamerClass = 'Unregistering streamer of unknown class: %s';
  SErrLimitNotSupported = 'Limit not supported by database backend';
  SErrInvalidSortField = 'Field "%s" cannot be sorted on';
  SErrInvalidSortDescField = 'Field "%s" cannot be sorted DESC';
  SErrInvalidBooleanForField = 'Invalid boolean value for NULL filter on field "%s"';
  SErrNoKeyParam = 'No key parameter specified';
  SErrUnknownOrUnSupportedFormat = 'Unknown or unsupported streaming format: %s';
  SUnauthorized = 'Unauthorized';
  SErrInvalidXMLInputMissingElement = 'Invalid XML input: missing %s element ';
  SErrInvalidXMLInput = 'Invalid XML input: %s';
  SErrMissingDocumentRoot = 'Missing document root';
  SErrInvalidCDSMissingElement = 'Invalid CDS Data packet: missing %s element';
  SErrNoResourceDataFound = 'Failed to find resource data in input';

Const
  DefaultAuthenticationRealm = 'REST API Server';
  ISODateTimeFormat = 'YYYY"-"mm"-"dd"T"hh":"nn":"ss"';
  ISODateFormat = ISODateTimeFormat;
  ISOTimeFormat = '"0000-00-00T"hh":"nn":"ss"';

implementation

end.

