Kernel.silence_warnings do
  Time.const_set('DATE_FORMATS', { :db => '%Y-%m-%d %H:%M:%S.%6N'})
end