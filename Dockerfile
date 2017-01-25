FROM scratch
ADD bin/linux/primes .
ENTRYPOINT ["./primes"]
CMD ["help"]