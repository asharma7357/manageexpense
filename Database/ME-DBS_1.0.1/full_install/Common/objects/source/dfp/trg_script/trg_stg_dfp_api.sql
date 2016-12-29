prompt
prompt Create trigger TRG_STG_DFP_API
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER TRG_STG_DFP_API before insert ON STG_DFP_API for each row
declare
	lv_inc_value	exception;
BEGIN
	if :new.key not in ('userAgentOS','userAgentBrowser','userAgentEngine','userAgentDevice',
						'displayColorDepth','displayScreenResolutionRatio','cpuArchitecture','canvas',
						'accept','acceptEncoding','acceptLanguage','ipAddress','ipAddressOctet','fonts',
						'language','timezone','navigatorPlatform','plugins','localStorage','sessionStorage',
						'doNotTrack','hasLiedLanguages','hasLiedOs','hasLiedBrowser','webGL','cookie',
						'touch','connection','webRTCSupport','videoCodecAvailable','audioCodecAvailable','indexedDb',
						'userAgentOSStartTime|userAgentOSEndTime','userAgentBrowserStartTime|userAgentBrowserEndTime',
						'userAgentEngineStartTime|userAgentEngineEndTime','userAgentDeviceStartTime|userAgentDeviceEndTime',
						'displayColorDepthStartTime|displayColorDepthEndTime',
						'displayScreenResolutionRatioStartTime|displayScreenResolutionRatioEndTime',
						'cpuArchitectureStartTime|cpuArchitectureEndTime','canvasStartTime|canvasEndTime',
						'acceptStartTime|acceptEndTime','acceptEncodingStartTime|acceptEncodingEndTime',
						'acceptLanguageStartTime|acceptLanguageEndTime','ipAddressStartTime|ipAddressEndTime',
						'ipAddressOctetStartTime|ipAddressOctetEndTime','fontsStartTime|fontsEndTime',
						'languageStartTime|languageEndTime','timezoneStartTime|timezoneEndTime',
						'navigatorPlatformStartTime|navigatorPlatformEndTime','pluginsStartTime|pluginsEndTime',
						'localStorageStartTime|localStorageEndTime','sessionStorageStartTime|sessionStorageEndTime',
						'doNotTrackStartTime|doNotTrackEndTime','hasLiedLanguagesStartTime|hasLiedLanguagesEndTime',
						'hasLiedOsStartTime|hasLiedOsEndTime','hasLiedBrowserStartTime|hasLiedBrowserEndTime',
						'webGLStartTime|webGLEndTime','cookieStartTime|cookieEndTime',
						'touchStartTime|touchEndTime','connectionStartTime|connectionEndTime',
						'webRTCSupportStartTime|webRTCSupportEndTime','videoCodecAvailableStartTime|videoCodecAvailableEndTime',
						'audioCodecAvailableStartTime|audioCodecAvailableEndTime','indexedDbStartTime|indexedDbEndTime') then
		raise lv_inc_value;
	end if;
exception
	when lv_inc_value then
		raise_application_error (-20001,:new.key||' Attrbute value provided is not configured.');
end;
/
