<?php

namespace App\Services\Agora;

/**
 * Agora AccessToken2 builder — token version 007.
 *
 * Matches the official Agora PHP SDK exactly:
 *   - All integers packed as little-endian (V = uint32-LE, v = uint16-LE)
 *   - Strings packed as uint16-LE length prefix + raw bytes
 *   - Compressed with raw DEFLATE (zlib_encode ZLIB_ENCODING_DEFLATE)
 *   - expire = duration in seconds (relative, NOT absolute timestamp)
 *   - Signing input = packString(appId) + packUint32(issueTs) + packUint32(salt)
 */
class AccessToken2
{
    const VERSION = '007';

    private string $appId;
    private string $appCert;
    private int    $expire;   // duration in seconds (relative)
    private int    $issueTs;
    private int    $salt;
    private array  $services = [];

    public function __construct(string $appId, string $appCert, int $expireSeconds = 3600)
    {
        $this->appId   = $appId;
        $this->appCert = $appCert;
        $this->issueTs = time();
        $this->expire  = $expireSeconds;           // relative duration (e.g. 3600)
        $this->salt    = random_int(1, 99_999_999);
    }

    public function addService(ServiceRtc $service): void
    {
        $this->services[$service->getServiceType()] = $service;
    }

    public function build(): string
    {
        $msg      = $this->buildMsg();
        $sign     = $this->getSign();
        $payload  = $sign . $msg;

        // Raw DEFLATE — matches zlib_encode($payload, ZLIB_ENCODING_DEFLATE) in the official SDK
        $compressed = zlib_encode($payload, ZLIB_ENCODING_DEFLATE);

        return self::VERSION . base64_encode($compressed);
    }

    // ── Private helpers ──────────────────────────────────────────────────────

    private function buildMsg(): string
    {
        $msg  = pack('V', $this->issueTs);            // uint32 LE
        $msg .= pack('V', $this->expire);             // uint32 LE (duration in seconds)
        $msg .= pack('V', $this->salt);               // uint32 LE

        ksort($this->services, SORT_NUMERIC);
        $msg .= pack('v', count($this->services));    // uint16 LE
        foreach ($this->services as $svc) {
            $msg .= $svc->pack();
        }
        return $msg;
    }

    /**
     * Signing key  = HMAC-SHA256( packString(appId) + packUint32(issueTs) + packUint32(salt) , appCert )
     * Signature    = HMAC-SHA256( buildMsg() , signingKey )
     */
    private function getSign(): string
    {
        // packString = uint16-LE length + raw bytes
        $input  = pack('v', strlen($this->appId)) . $this->appId;
        $input .= pack('V', $this->issueTs);
        $input .= pack('V', $this->salt);

        $signingKey = hash_hmac('sha256', $input, $this->appCert, true);
        return hash_hmac('sha256', $this->buildMsg(), $signingKey, true);
    }
}
