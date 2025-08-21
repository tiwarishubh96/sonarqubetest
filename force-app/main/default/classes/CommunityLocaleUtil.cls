public class CommunityLocaleUtil {

    //static maps
    public static final Map<String, String> lang2key = new Map<String, String> {
        'en' => 'en_US', 'ja' => 'ja', 'zh' => 'zh_CN',
        'da' => 'da', 'du' => 'nl_NL',
        'fi' => 'fi', 'fr' => 'fr', 'de' => 'de', 'it' => 'it', 'ko' => 'ko',
        'no' => 'no', 'pt' => 'pt_BR', 'ru' => 'ru', 'es' => 'es',
        'sv' => 'sv', 'th' => 'th', 'ar' => 'ar', 'bg' => 'bg', 'cs' => 'cs',
            'en_GB' => 'en_GB', 'el' => 'el', 'es_MX' => 'es_MX', 'iw' => 'iw',
            'hu' => 'hu', 'in' => 'in', 'no' => 'no', 'pl' => 'pl', 'ro' => 'ro',
            'tr' => 'tr', 'uk' => 'uk', 'vi' => 'vi', 'sq' => 'sq', 'hy' => 'hy', 
            'eu' => 'eu', 'bs' => 'bs', 'hr' => 'hr', 'en_AU' => 'en_AU', 'en_CA' => 'en_CA',
            'en_IN' => 'en_IN', 'en_MY' => 'en_MY', 'en_PH' => 'en_PH', 'et' => 'et', 
            'fr_CA' => 'fr_CA', 'ka' => 'ka', 'hi' => 'hi', 'is' => 'is', 'ga' => 'ga',
            'lv' => 'lv', 'lt' => 'lt', 'lb' => 'lb', 'mk' => 'mk', 'mt' => 'mt', 'ms' => 'ms',
            'ro_MD' => 'ro_MD', 'sh_ME' => 'sh_ME', 'pt_PT' => 'pt_PT', 'rm' => 'rm',
            'sr' => 'sr', 'sh' => 'sh', 'sk' => 'sk', 'sl' => 'sl', 'tl' => 'tl', 'ur' => 'ur',
            'cy' => 'cy'            
    };

    public static final Map<String, String> langLocale2key = new Map<String, String> {
        'en_US' => 'en_US', 'de_DE' => 'de', 'fr_FR' => 'fr', 'es_ES' => 'es', 'fr_CA' => 'fr_CA',
         'en_GB' => 'en_GB', 'en_CA' => 'en_CA',    
            'ja' => 'ja', 'zh' => 'zh_CN',
        'da' => 'da', 'du' => 'nl_NL',
        'fi' => 'fi',  'it' => 'it', 'ko' => 'ko',
        'no' => 'no', 'pt' => 'pt_BR', 'ru' => 'ru', 
        'sv' => 'sv', 'th' => 'th', 'ar' => 'ar', 'bg' => 'bg', 'cs' => 'cs',
             'el' => 'el', 'es_MX' => 'es_MX', 'iw' => 'iw',
            'hu' => 'hu', 'in' => 'in', 'no' => 'no', 'pl' => 'pl', 'ro' => 'ro',
            'tr' => 'tr', 'uk' => 'uk', 'vi' => 'vi', 'sq' => 'sq', 'hy' => 'hy', 
            'eu' => 'eu', 'bs' => 'bs', 'hr' => 'hr', 'en_AU' => 'en_AU', 
            'en_IN' => 'en_IN', 'en_MY' => 'en_MY', 'en_PH' => 'en_PH', 'et' => 'et', 
             'ka' => 'ka', 'hi' => 'hi', 'is' => 'is', 'ga' => 'ga',
            'lv' => 'lv', 'lt' => 'lt', 'lb' => 'lb', 'mk' => 'mk', 'mt' => 'mt', 'ms' => 'ms',
            'ro_MD' => 'ro_MD', 'sh_ME' => 'sh_ME', 'pt_PT' => 'pt_PT', 'rm' => 'rm',
            'sr' => 'sr', 'sh' => 'sh', 'sk' => 'sk', 'sl' => 'sl', 'tl' => 'tl', 'ur' => 'ur',
            'cy' => 'cy'            
    };

	//static maps
    public static final Map<String, String> country2key = new Map<String, String> {
        'us' => 'en_US', 'de' => 'de_DE', 'es' => 'es_ES',
        'fr' => 'fr_FR', 'ca' => 'en_CA', 'gb' => 'en_GB'
    };
}