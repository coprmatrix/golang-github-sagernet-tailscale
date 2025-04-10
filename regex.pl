s~%global\s+goipath\s+(.*)/(.*)~%global goihead \2\n%global goipath \1/%{goihead}~g;

s~(Version:)\s*([^0-9\.]*)([0-9\.]*)([^\s]*)\s*~\1  \3\n%define oldver \2\3\4\n~g;
s~(^%gometa.*)~%{?!tag:%{?!commit:%global tag v%{oldver}}}\n\1\n~g;

my $text = << 'EOF';
shopt -s globstar

for i in go.mod go.sum
do
  sed -i "s~github.com/tailscale/xnet~~g;s~github.com/tailscale/netlink~~g;s~github.com/tailscale/wireguard-go~~g;" "${i}"
done

for i in **/* */*
do
  if test -f ${i}
  then
    sed -i "s~github.com/tailscale/wireguard-go~github.com/sagernet/wireguard-go~g;s~github.com/tailscale/netlink~github.com/sagernet/netlink~g;s~github.com/tailscale/xnet~golang.org/x/net~g;s~tailscale.com/util/singleflight~github.com/sagernet/tailscale/util/singleflight~g;s~tailscale.com/atomicfile~github.com/sagernet/tailscale/atomicfile~g;s~github.com/fxamacker/cbor/v2~github.com/fxamacker/cbor~g;s~github.com/illarion/gonotify/v2~github.com/illarion/gonotify~g;s~github.com/jellydator/ttlcache/v3~github.com/jellydator/ttlcache~g;" "${i}"
  fi
done

EOF

s~(%goprep.*)~\1\n$text~g;
s~(.*%gopkginstall.*)~\1\n mkdir -p %{buildroot}%{_datadir}/doc/%{name}/example~g;
s~wgengine/bench~~g;
s~%gocheck~~g;
s~Source:.*~%define scommit %{?commit}%{?!commit:v%{version}}\n%define stag %{?tag}%{?!tag:%scommit}\nSource: https://%{goipath}/archive/%{stag}/%{goihead}-%{stag}.tar.gz~g;
