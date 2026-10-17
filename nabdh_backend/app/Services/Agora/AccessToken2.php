<?php

namespace App\Services\Agora;

/**
 * Agora AccessToken2 builder — token version 007.
 *
 * Byte layout follows the official AgoraIO/Tools PHP AccessToken2:
 *   signing key = HMAC(HMAC(appCert, key=uint32(issueTs)), key=uint32(salt))
 *   body        = str(appId) . uint32(issueTs) . uint32(expire) . uint32(salt)
 *                 . uint16(count) . services (sorted by type)
 *   token       = "007" . base64(deflate(str(HMAC(body, signingKey)) . body))
 * Integers are little-endian; str() = uint16 length + bytes.
 * `expire` and privilege expiries are seconds relative to issueTs.
 */
class AccessToken2
{
    const VERSION = '007';

    private string $appId;
    private string $appCert;
    private int    $expire;
    private int    $issueTs;
    private int    $salt;
    private array  $services = [];

    public function __construct(string $appId, string $appCert, int $expireSeconds = 3600)
    {
        $this->appId   = $appId;
        $this->appCert = $appCert;
        $this->issueTs = time();
        $this->expire  = $expireSeconds;
        $this->salt    = random_int(1, 99_999_999);
    }

    public function addService(ServiceRtc $service): void
    {
        $this->services[$service->getServiceType()] = $service;
    }

    public function build(): string
    {
        ksort($this->services, SORT_NUMERIC);

        $body = self::packString($this->appId)
            . pack('V', $this->issueTs)
            . pack('V', $this->expire)
            . pack('V', $this->salt)
            . pack('v', count($this->services));
        foreach ($this->services as $svc) {
            $body .= $svc->pack();
        }

        $signature = hash_hmac('sha256', $body, $this->signingKey(), true);

        return self::VERSION . base64_encode(
            zlib_encode(self::packString($signature) . $body, ZLIB_ENCODING_DEFLATE)
        );
    }

    private function signingKey(): string
    {
        $key = hash_hmac('sha256', $this->appCert, pack('V', $this->issueTs), true);
        return hash_hmac('sha256', $key, pack('V', $this->salt), true);
    }

    public static function packString(string $value): string
    {
        return pack('v', strlen($value)) . $value;
    }
}
