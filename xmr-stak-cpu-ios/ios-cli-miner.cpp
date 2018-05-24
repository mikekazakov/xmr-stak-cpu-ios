 /*
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  *
  * Additional permission under GNU GPL version 3 section 7
  *
  * If you modify this Program, or any covered work, by linking or combining
  * it with OpenSSL (or a modified version of that library), containing parts
  * covered by the terms of OpenSSL License and SSLeay License, the licensors
  * of this Program grant you additional permission to convey the resulting work.
  *
  */

#include <xmrstak/misc/executor.hpp>
#include <xmrstak/backend/miner_work.hpp>
#include <xmrstak/backend/globalStates.hpp>
#include <xmrstak/backend/backendConnector.hpp>
#include <xmrstak/jconf.hpp>
#include <xmrstak/misc/console.hpp>
#include <xmrstak/donate-level.hpp>
#include <xmrstak/params.hpp>
#include <xmrstak/misc/configEditor.hpp>
#include <xmrstak/version.hpp>
#include <xmrstak/misc/utility.hpp>
#include <xmrstak/backend/cpu/minethd.hpp>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#ifndef CONF_NO_TLS
#include <openssl/ssl.h>
#include <openssl/err.h>
#endif

int miner_main(int argc, char *argv[])
{
#ifndef CONF_NO_TLS
	SSL_library_init();
	SSL_load_error_strings();
	ERR_load_BIO_strings();
	ERR_load_crypto_strings();
	SSL_load_error_strings();
	OpenSSL_add_all_digests();
#endif

	srand(time(0));

	const char* sFilename = argv[1];
    const char* sPools = argv[2];

    xmrstak::params::inst().configFileCPU = argv[3];
	if(!jconf::inst()->parse_config(sFilename, sPools))
	{
		win_exit();
		return 0;
	}

    if (!xmrstak::cpu::minethd::self_test())
	{
		win_exit();
		return 0;
	}

    printer::inst()->print_str("-------------------------------------------------------------------\n");
    printer::inst()->print_str(get_version_str_short().c_str());
    printer::inst()->print_str("\n\n");
    printer::inst()->print_str("Brought to you by fireice_uk and psychocrypt under GPLv3.\n");
    printer::inst()->print_str("Based on CPU mining code by wolf9466 (heavily optimized by fireice_uk).\n");
#ifndef CONF_NO_CUDA
    printer::inst()->print_str("Based on NVIDIA mining code by KlausT and psychocrypt.\n");
#endif
#ifndef CONF_NO_OPENCL
    printer::inst()->print_str("Based on OpenCL mining code by wolf9466.\n");
#endif
    printer::inst()->print_str("iOS port was made by Michael Kazakov.\n\n");    
    char buffer[64];
    snprintf(buffer, sizeof(buffer), "\nConfigurable dev donation level is set to %.1f%%\n\n", fDevDonationLevel * 100.0);
    printer::inst()->print_str(buffer);
    printer::inst()->print_str("You can use following keys to display reports:\n");
    printer::inst()->print_str("'h' - hashrate\n");
    printer::inst()->print_str("'r' - results\n");
    printer::inst()->print_str("'c' - connection\n");
    printer::inst()->print_str("-------------------------------------------------------------------\n");
    printer::inst()->print_msg(L0, "Mining coin: %s", jconf::inst()->GetMiningCoin().c_str());

	if(strlen(jconf::inst()->GetOutputFile()) != 0)
		printer::inst()->open_logfile(jconf::inst()->GetOutputFile());

	executor::inst()->ex_start(jconf::inst()->DaemonMode());

	using namespace std::chrono;
	uint64_t lastTime = time_point_cast<milliseconds>(high_resolution_clock::now()).time_since_epoch().count();

	int key;
	while(true)
	{
		key = get_key();

		switch(key)
		{
		case 'h':
			executor::inst()->push_event(ex_event(EV_USR_HASHRATE));
			break;
		case 'r':
			executor::inst()->push_event(ex_event(EV_USR_RESULTS));
			break;
		case 'c':
			executor::inst()->push_event(ex_event(EV_USR_CONNSTAT));
			break;
		default:
			break;
		}

		uint64_t currentTime = time_point_cast<milliseconds>(high_resolution_clock::now()).time_since_epoch().count();

		/* Hard guard to make sure we never get called more than twice per second */
		if( currentTime - lastTime < 500)
			std::this_thread::sleep_for(std::chrono::milliseconds(500 - (currentTime - lastTime)));
		lastTime = currentTime;
	}

	return 0;
}

extern "C" void run_main_miner(const char *_config, const char *_pools, const char *_cpu)
{
    std::string conf = _config;
    std::string pools = _pools;
    std::string cpu = _cpu;
    std::thread([conf, pools, cpu]{
        const char *argv[] = {"miner", conf.c_str(), pools.c_str(), cpu.c_str()};
        miner_main(2, (char **)argv);
    }).detach();
}

extern "C" void invoke_print_hash()
{
    executor::inst()->push_event(ex_event(EV_USR_HASHRATE));
}

extern "C" void invoke_print_results()
{
    executor::inst()->push_event(ex_event(EV_USR_RESULTS));
}

extern "C" void invoke_print_connection()
{
    executor::inst()->push_event(ex_event(EV_USR_CONNSTAT));
}
