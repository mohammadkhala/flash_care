<?php

namespace App\Services\Agora;

/**
 * Agora AccessToken2 builder (token version 007).
 *
 * Token structure (after base64 + zlib decompression):
 *   [32-byte HMAC-SHA256 signature] + [packed message]
 *
 * Packed message:
 *   issueTs(uint32) | expire(uint32) | salt(uint32) | services_count(uint16)
 *   + one ServiceRtc packed entry
 *
 * Signing key  = HMAC-SHA256( appId + issueTs + salt , appCertificate )
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
        $this->expire  = $expireSeconds;
        $this->issueTs = time();
        $this->salt    = random_int(1, 99_999_999);
    }

    public function addService(ServiceRtc $service): void
    {
        $this->services[$service->getServiceType()] = $service;
    }

    public function build(): string
    {
        $msg     = $this->buildMsg();
        $signing = $this->getSign();
        $payload = $signing . $msg;

        return self::VERSION . base64_encode(gzcompress($payload));
    }

    // ── Private helpers ──────────────────────────────────────────────────────

    private function buildMsg(): string
    {
        $msg  = pack('N', $this->issueTs);
        $msg .= pack('N', $this->expire);
        $msg .= pack('N', $this->salt);

        ksort($this->services);
        $msg .= pack('n', count($this->services));
        foreach ($this->services as $svc) {
            $msg .= $svc->pack();
        }
        return $msg;
    }

    /**
     * Signing key  = HMAC-SHA256( appId + issueTs + salt , appCertificate )
     * Signature    = HMAC-SHA256( buildMsg() , signingKey )
     */
    private function getSign(): string
    {
        $signingKey = hash_hmac(
            'sha256',
            $this->appId . pack('N', $this->issueTs) . pack('N', $this->salt),
            $this->appCert,
            true,
        );
        return hash_hmac('sha256', $this->buildMsg(), $signingKey, true);
    }
}
