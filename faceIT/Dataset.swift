//
//  Dataset.swift
//  faceIT
//
//  Created by Alibek Manabayev on 9/16/18.
//  Copyright © 2018 NovaTec GmbH. All rights reserved.
//

import Foundation
import Vision
import Surge

class Dataset {
    var data: [[Double]]
    var labels: [String]
    init() {
        data = []
        labels = []
        augment_dataset()
    }
    func find_closest(observation: VNCoreMLFeatureValueObservation) -> String? {
        let feature = getDoubleArray(observation: observation)
        print(feature)
        var idx = 0
        var min_dist = dist(feature, y: data[idx])
        print("---------------")
        for i in 0..<data.count {
            let cur_dist = dist(feature, y: data[i])
            if cur_dist < min_dist {
                idx = i
                min_dist = cur_dist
            }
            print(cur_dist)
        }
        if min_dist < 0.8 {
            return labels[idx]
        }
        return nil
    }
}

extension Dataset {
    
    func getDoubleArray(observation: VNCoreMLFeatureValueObservation) -> [Double] {
        let mm = observation.featureValue.multiArrayValue!
        let length = mm.count
        let doublePtr =  mm.dataPointer.bindMemory(to: Double.self, capacity: length)
        let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: length)
        let output = Array(doubleBuffer)
        return output
    }
    
    func augment_dataset() {
        labels.append("Unknown")
        data.append( [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,])
        labels.append("Miras")
        data.append(
        [0.07964446395635605,-0.0138948829844594,0.06566587835550308,-0.1196131780743599,0.08286707103252411,0.1606281995773315,0.04281465336680412, 0.1088990569114685,-0.1985461562871933,0.01086060889065266,-0.02358363382518291,0.04641393199563026,0.1463984996080399,0.06085289269685745, 0.09776640683412552,-0.08542004972696304,-0.01123727764934301,-0.0111535731703043,-0.02492289990186691,0.1705889850854874,0.09433453530073166, -0.007004987914115191,0.1169346496462822,0.03214237838983536,-0.09249304980039597,0.01266024727374315,-0.1361865997314453,-0.08897747099399567, 0.09517157822847366,-0.02486012130975723,-0.07194368541240692,-0.02894069813191891,-0.04340058192610741,0.05026432126760483,-0.01359145529568195, 0.0159037820994854,-0.03498832136392593,0.2511123418807983,-0.02753865346312523,-0.01344497315585613,-0.006345818284898996,0.06131326407194138, -0.1464821994304657,-0.1128331497311592,-0.2065817564725876,-0.01055194996297359,0.04733467847108841,-0.005071946419775486,-0.1273976564407349, 0.08039779961109161,-0.07508259266614914,0.01788129098713398,-0.04461429268121719,0.1154279783368111,0.05428211763501167,-0.0483391247689724, 0.08655005693435669,0.1263932138681412,-0.1166835352778435,-0.09508787840604782,-0.0648706927895546,0.08487597107887268,0.1334243565797806, -0.1331732422113419,0.07298998534679413,0.06102029979228973,0.05022246763110161,0.1126657426357269,-0.09458564966917038,-0.02283029817044735, 0.07805408537387848,0.09391601383686066,-0.02829199098050594,0.07663111388683319,0.05562138557434082,0.06809329986572266,-0.06323845684528351, -0.1005286425352097,0.1913476139307022,0.03622295707464218,-0.09182341396808624,-0.002989806467667222,0.0559980534017086,0.003947172313928604, 0.02563438564538956,-0.06650292128324509,0.09123748540878296,0.1294065564870834,0.1100709140300751,0.01486794371157885,0.1143398210406303, -0.08043965697288513,0.07721704989671707,0.1039605140686035,-0.06708884984254837,-0.2077536135911942,0.03733203560113907,0.1161813139915466, -0.03402572125196457,-0.01294274907559156,0.04352613911032677,0.05223136767745018,-0.08006298542022705,0.07060442119836807,-0.1400369852781296, 0.1340939998626709,-0.02439974993467331,-0.0140936803072691,0.08989822119474411,-0.09868714958429337,0.04624652490019798,0.1263095140457153, -0.04021982848644257,0.03214237838983536,0.06374068558216095,0.0987708568572998,-0.1046301424503326,-0.06922329962253571,-0.07215294986963272, 0.1171857640147209,-0.06265252828598022,-0.1034582853317261,-0.004980395082384348,-0.01102801691740751,-0.03132626414299011,0.1327547281980515, 0.006816654000431299,-0.008265781216323376])
        labels.append("Alibek")
        data.append([0.028892749920487404, -0.13615213334560394, 0.037394341081380844, -0.080424748361110687, 0.080424748361110687, 0.059590306133031845, 0.047336611896753311, 0.094989858567714691, 0.014335553161799908, -0.08321111649274826, -0.01955207996070385, 0.11189805716276169, 0.17832763493061066, -0.061838399618864059, -0.080171443521976471, -0.085554197430610657, -0.1056920513510704, 0.035906165838241577, -0.19251278042793274, 0.20568470656871796, 0.20378491282463074, -0.065796308219432831, 0.018792159855365753, 0.12431006133556366, -0.13501225411891937, -0.0026913792826235294, -0.14071165025234222, -0.1741480827331543, -0.014968818984925747, 0.027911188080906868, 0.0068669752217829227, -0.0057904236018657684, -0.062756635248661041, 0.02377912774682045, -0.004781156312674284, 0.0099501879885792732, -0.10841509699821472, 0.17541460692882538, -0.11069484800100327, -0.037837628275156021, 0.046228397637605667, 0.042048845440149307, -0.14603108167648315, 0.10182913392782211, -0.11265797168016434, -0.15628997981548309, 0.016211602836847305, 0.032454870641231537, 0.014129742048680782, 0.043062068521976471, -0.072762235999107361, -0.14869078993797302, -0.047304950654506683, 0.034386329352855682, 0.085237570106983185, -0.032423205673694611, -0.071115739643573761, 0.11006158590316772, -0.069152615964412689, -0.15780982375144958, 0.010947581380605698, -0.0060476879589259624, 0.1120247095823288, 0.058608744293451309, 0.0055569070391356945, -0.15426352620124817, 0.075928561389446259, 0.062313348054885864, 0.016172023490071297, -0.10619866102933884, 0.072128966450691223, 0.035082921385765076, 0.050312962383031845, -0.061711747199296951, -0.079158216714859009, 0.052022781223058701, -0.11436779052019119, -0.010813012719154358, 0.10822511464357376, 0.13906516134738922, -0.020755285397171974, 0.013037358410656452, -0.0069500915706157684, -0.0026280528400093317, -0.027182931080460548, -0.0093090059235692024, 0.17908754944801331, 0.14489120244979858, 0.060983490198850632, -0.064308136701583862, 0.042967081069946289, -0.10201910883188248, 0.021800173446536064, 0.026597160845994949, -0.1661689281463623, -0.12082710117101669, -0.048856452107429504, -0.015301283448934555, -0.056962251663208008, -0.0040568588301539421, 0.081627950072288513, -0.011660004965960979, -0.075928561389446259, 0.067062839865684509, -0.053289312869310379, 0.026058884337544441, -0.10151249915361404, 0.050281301140785217, 0.025251470506191254, -0.019599573686718941, -0.012760304845869541, 0.084414325654506683, -0.18339376151561737, 0.02455487847328186, -0.016892364248633385, 0.15021063387393951, -0.13501225411891937, -0.060128580778837204, -0.12829963862895966, 0.070862434804439545, -0.11398783326148987, 0.036729414016008377, -0.072445601224899292, 0.032929819077253342, -0.070419147610664368, 0.043568681925535202, -0.12374012172222137, -0.012309102341532707])
        labels.append("Alibek")
        data.append([0.13358315825462341, -0.0042662834748625755, 0.047419726848602295, 0.0031129238195717335, 0.056371178478002548, 0.14515119791030884, 0.13881632685661316, 0.077441513538360596, 0.032546550035476685, -0.10043985396623611, -0.014356747269630432, 0.049990400671958923, 0.14983348548412323, -0.15111882984638214, -0.062568336725234985, -0.012210695073008537, -0.0040855333209037781, -0.023216387256979942, -0.22530108690261841, 0.16801181435585022, 0.19390216469764709, -0.0011447526048868895, -0.070555783808231354, 0.15837179124355316, -0.10787644237279892, -0.077579230070114136, -0.21777269244194031, -0.16553294658660889, 0.056830227375030518, 0.11072254180908203, 0.038743708282709122, 0.055039934813976288, -0.11742465198040009, 0.080838471651077271, 0.019899759441614151, -0.052606977522373199, 0.0077866134233772755, 0.14964987337589264, -0.035920560359954834, -0.050724878907203674, 0.00023472450266126543, 0.010667143389582634, -0.047144297510385513, 0.0062086335383355618, 0.010546643286943436, -0.12890087068080902, 0.017719278112053871, 0.00064266816480085254, -0.030664451420307159, 0.079369515180587769, 0.025155868381261826, -0.092681929469108582, -0.016181465238332748, 0.036907512694597244, 0.092681929469108582, -0.048934590071439743, -0.080608949065208435, 0.080838471651077271, -0.018740661442279816, -0.1428559422492981, -0.032477695494890213, -0.0098351174965500832, 0.062568336725234985, -0.14258052408695221, -0.0069947540760040283, -0.14937444031238556, 0.097042888402938843, -0.051642976701259613, -0.12128066271543503, -0.16507390141487122, 0.034520462155342102, 0.01923413947224617, -0.01851113885641098, -0.012876315042376518, -0.084189526736736298, 0.032087501138448715, 0.017879946157336235, 0.028506923466920853, 0.11035530269145966, 0.19133149087429047, 0.064634054899215698, -0.019027568399906158, 0.0060537043027579784, -0.001270991051569581, 0.098328225314617157, -0.013622269965708256, 0.078084178268909454, 0.037091132253408432, 0.030090641230344772, 0.016376562416553497, 0.02352624386548996, -0.15736187994480133, -0.050724878907203674, 0.086943820118904114, -0.12734010815620422, -0.015515845268964767, 0.036861609667539597, -0.047006584703922272, -0.075238078832626343, 0.068214632570743561, 0.08024170994758606, 0.050128117203712463, -0.11935265362262726, 0.16892991960048676, -0.13101249933242798, 0.0017730755498632789, -0.036471419036388397, 0.046547535806894302, 0.034864746034145355, 0.016410989686846733, -0.015251892618834972, 0.061512522399425507, -0.17315316200256348, 0.027405206114053726, 0.0038560088723897934, 0.13661289215087891, -0.13404221832752228, 0.013094363734126091, -0.18609833717346191, 0.064863577485084534, -0.12063799053430557, 0.063348717987537384, 0.033189218491315842, 0.053066026419401169, 0.030228355899453163, 0.014310842379927635, -0.056738417595624924, -0.11613931506872177])
        labels.append("Alibek")
        data.append([0.099125213921070099, -0.04022878035902977, 0.0370786152780056, 0.039388738572597504, 0.16324858367443085, 0.15848833322525024, 0.14411424100399017, -0.01587916724383831, -0.012017298489809036, -0.067903570830821991, -0.06823025643825531, 0.034908503293991089, 0.12647330760955811, -0.0701436847448349, 0.034605152904987335, -0.011282259598374367, 0.05189606174826622, 0.098565183579921722, -0.13543379306793213, 0.095858372747898102, 0.17575590312480927, 0.0072803827933967113, -0.003109330078586936, 0.17911608517169952, -0.028071476146578789, -0.13160692155361176, -0.23745247721672058, -0.22793197631835938, -0.0029372377321124077, 0.12955348193645477, 0.061836585402488708, 0.088577993214130402, -0.11676613986492157, 0.057263009250164032, 0.11797953397035599, -0.0098821865394711494, 0.05124269425868988, 0.049282591789960861, -0.037778653204441071, -0.10799234360456467, 0.074903935194015503, 0.050029296427965164, 0.013265697285532951, -0.0086979568004608154, -0.093011558055877686, -0.019204342737793922, 0.054416194558143616, 0.036448583006858826, -0.0041914703324437141, -0.024197937920689583, 0.058569744229316711, -0.17883606255054474, 0.069070294499397278, 0.0051277694292366505, 0.10752565413713455, -0.003050993662327528, 0.016054177656769753, 0.079850867390632629, 0.060996539890766144, -0.11312595009803772, -8.964663720689714e-05, 0.066550165414810181, -0.039178725332021713, -0.17986278235912323, 0.082044310867786407, -0.12413986027240753, 0.038782037794589996, -0.015704158693552017, -0.089184686541557312, -0.093058228492736816, 0.034908503293991089, 0.07187044620513916, -0.026041368022561073, -0.13562045991420746, -0.097445122897624969, 0.10267206281423569, -0.044405668973922729, 0.078684136271476746, 0.10015193372964859, 0.089978061616420746, 0.038992051035165787, 0.065056756138801575, -0.016147514805197716, 0.02345123328268528, 0.067203529179096222, 0.0026820159982889891, 0.087364591658115387, 0.020779425278306007, -0.10957909375429153, 0.020942768082022667, 0.035235185176134109, -0.077937431633472443, -0.0011893333867192268, -0.021234448999166489, -0.17435583472251892, -0.0084121087566018105, 0.0042381393723189831, 0.057403016835451126, -0.027208097279071808, 0.055769599974155426, 0.13468708097934723, 0.053716156631708145, -0.027814796194434166, 0.1249799057841301, -0.084517776966094971, -0.06384335458278656, -0.061509899795055389, 0.019612697884440422, -0.014700773172080517, 0.1031387522816658, -0.043868973851203918, -0.017174236476421356, -0.10500551760196686, -0.057823039591312408, -0.034278467297554016, 0.14206080138683319, -0.18126286566257477, -0.032015014439821243, -0.2602270245552063, 0.068603605031967163, -0.049189250916242599, 0.048582553863525391, -0.046645786613225937, 0.039038717746734619, -0.041115496307611465, 0.05618961900472641, -0.13916730880737305, -0.08713124692440033])
    }
}
