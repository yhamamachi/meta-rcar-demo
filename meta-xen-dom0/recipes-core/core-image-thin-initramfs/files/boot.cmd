# Common function
setenv imx708_read_id '
    # Get device ID
    i2c olen 0x1a 2
    i2c read 0x1a 0x0016 2 0x48000000
    # Swap byte
    setexpr.b id_high *0x48000000
    setexpr.b id_low  *0x48000001
    setexpr chip_id ${id_high} * 0x100
    setexpr chip_id ${chip_id} + ${id_low}
'
echo ''
echo --- Check J1 ---;
i2c dev 1
if i2c probe 0x10; then
    echo IMX219 is detected;
    setenv j1_conf '#j1-imx219';
fi
if i2c probe 0x1a; then
    run imx708_read_id
    if test 0x${chip_id} -eq 0x0708; then
        echo IMX708 is detected;
        setenv j1_conf '#j1-imx708'
    else
        echo Fallback to IMX462;
        setenv j1_conf '#j1-imx462'
    fi
fi

echo --- Check J2 ---;
i2c dev 2
if i2c probe 0x10; then
    echo  IMX219 is detected;
    setenv j2_conf '#j2-imx219';
fi
if i2c probe 0x1a; then
    run imx708_read_id
    if test 0x${chip_id} -eq 0x0708; then
        echo IMX708 is detected;
        setenv j2_conf '#j2-imx708'
    else
        echo Fallback to IMX462;
        setenv j2_conf '#j2-imx462'
    fi
fi

echo --- Check J4 ---;
i2c dev 0 && i2c mw 0x71 0x0 0x7 && i2c speed 100000
if i2c probe 0x45; then
    # Power on I2C display
    i2c mw 0x45 0x02 0x00 && sleep 0.1 && i2c mw 0x45 0x02 0x03 && sleep 0.1

    # Raspberry Pi Touch Display Case
    if i2c probe 0x5d; then
        i2c read 0x5d 0x8047.2 0x1 0x48000000
        setexpr.b config_version *0x48000000
        if test 0x${config_version} -eq 0x41; then
            echo Raspberry Pi Touch Display 2 7inch model is detected;
            setenv j4_conf '#rpi-display-2-7in';
        fi
        if test 0x${config_version} -eq 0x42; then
            echo Raspberry Pi Touch Display 2 5inch model is detected;
            setenv j4_conf '#rpi-display-2-5in';
        fi
    fi
    # Waveshare panel case
    if i2c probe 0x41; then
        echo Waveshare panel is detected;
        setenv j4_conf '#waveshare-panel';
    fi
fi

# Check FAN
#setenv fan_conf ''
#if test "${fan}" -eq "pwm" ; then
#    setenv fan_conf '#fan-pwm'
#fi
#if test "${fan}" -eq "argon40" ; then
#    i2c dev 3
#    if i2c probe 0x1a; then
#        setenv fan_conf '#fan-argon40'
#    fi
#fi

echo --- Check Boot device ---;
# extract boot device from bootargs
#setenv bootdev ${bootargs}
#setexpr bootdev gsub ".*root=/dev/" ""
#setexpr bootdev gsub "[0-9].*" ""
#
# Check whether initramfs is needed or not
# if itest.s "${bootdev}" != "mmcblk"; then
#     echo Boot device is not MMC, so initramfs is used.
# else
#     echo Boot device is MMC.
# fi
setenv initramfs_conf '#default'

echo --- Booting ---;
setenv conf "${initramfs_conf}${j1_conf}${j2_conf}${j4_conf}${fan_conf}${conf_append}"
echo bootcmd: bootm ${loadaddr}${conf}
bootm ${loadaddr}${conf}

